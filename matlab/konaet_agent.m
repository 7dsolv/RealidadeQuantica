function [policy, next_memory] = konaet_agent(memory_history, observations)
%KONAET_AGENT Recurrent experimental agent for the scientific lab.
%   With memory_history alone, return the next bounded simulation policy.
%   With observations, also return one 16-column persistent memory record.
%   This small numerical model is not a claim of consciousness or general AI.

if nargin < 2
    observations = [];
end
if ~isnumeric(memory_history) || isempty(memory_history) ...
        || size(memory_history, 2) ~= 16 || any(~isfinite(memory_history(:)))
    error('memory_history precisa ser uma matriz numerica finita de 16 colunas.');
end

previous = memory_history(end, :);
cycle = previous(1) + 1;
identity = previous(2:5);

policy.cycle = cycle;
policy.beta = 5.5 + 0.18 * tanh(identity(1));
policy.step_size = 0.35 + 0.08 * tanh(identity(2));
policy.seed = mod(round(1e6 * abs(identity * [1; 2; 3; 4])) ...
    + cycle * 104729 + 7, 2147483646) + 1;
policy.ramsey_phase = mod(0.8 + 0.11 * cycle ...
    + pi * identity(3) - pi * identity(4), 2 * pi);
policy.ramsey_probability = sin(policy.ramsey_phase / 2)^2;
next_memory = [];

if isempty(observations)
    return;
end
required_fields = {'wilson_mean', 'acceptance', 'wave_spread', 'deceleration'};
if ~isstruct(observations) || ~all(isfield(observations, required_fields))
    error('Observacoes devem conter Wilson, acceptance, wave_spread e deceleration.');
end
observed_values = [observations.wilson_mean, observations.acceptance, ...
    observations.wave_spread, observations.deceleration];
if any(~isfinite(observed_values))
    error('As observacoes do agente precisam ser finitas.');
end

features = [2 * observations.wilson_mean - 1; ...
    2 * observations.acceptance - 1; ...
    min(1, (observations.wave_spread - 1) / 3); ...
    observations.deceleration; ...
    2 * policy.ramsey_probability - 1];
input_weights = [0.35, -0.10, 0.20, 0.25, 0.30; ...
    -0.15, 0.40, 0.30, -0.20, 0.25; ...
    0.20, 0.25, -0.10, 0.35, -0.30; ...
    0.30, -0.15, 0.25, 0.20, 0.10];
recurrent_weights = [0.45, 0.12, -0.08, 0.04; ...
    0.05, 0.42, 0.10, -0.06; ...
    -0.07, 0.08, 0.40, 0.11; ...
    0.09, -0.05, 0.06, 0.43];
next_identity = tanh(0.72 * recurrent_weights * identity(:) ...
    + 0.50 * input_weights * features);
predicted_signal = 0.5 + 0.25 * mean(identity);
observed_signal = mean([observations.wilson_mean, ...
    observations.acceptance, policy.ramsey_probability]);
prediction_error = abs(observed_signal - predicted_signal);
curiosity = min(1, max(0, 0.82 * previous(6) ...
    + 0.18 * prediction_error));
coherence = 1 - mean(abs(next_identity(:).' - identity)) / 2;

next_memory = [cycle, next_identity(:).', curiosity, coherence, ...
    policy.ramsey_phase, policy.beta, policy.seed, ...
    observations.wilson_mean, observations.acceptance, ...
    observations.wave_spread, observations.deceleration, ...
    policy.ramsey_probability, prediction_error];
end
