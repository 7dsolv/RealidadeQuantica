function [history, final_plaquettes, acceptance, links, lattice] = ...
    run_su3_lattice(beta, measurements, step_size, seed, progress_callback)
%RUN_SU3_LATTICE Metropolis sampler for a tiny 2^4 pure-gauge SU(3) lattice.
%   This is an educational finite-lattice model. It has no dynamical quarks
%   and is not a proton calculation.

if nargin < 5
    progress_callback = [];
end
if beta <= 0 || measurements < 1 || step_size <= 0
    error('beta, medições e passo precisam ser positivos.');
end

measurements = round(measurements);
rng(round(seed), 'twister');

lattice.side = 2;
lattice.n_directions = 4;
lattice.n_sites = lattice.side^lattice.n_directions;
lattice.forward = zeros(lattice.n_sites, lattice.n_directions);
lattice.backward = zeros(lattice.n_sites, lattice.n_directions);

shape = lattice.side * ones(1, lattice.n_directions);
coordinates = zeros(lattice.n_sites, lattice.n_directions);
for site = 1:lattice.n_sites
    [i1, i2, i3, i4] = ind2sub(shape, site);
    coordinates(site, :) = [i1, i2, i3, i4] - 1;
end

for site = 1:lattice.n_sites
    for mu = 1:lattice.n_directions
        forward_coordinates = coordinates(site, :);
        forward_coordinates(mu) = mod(forward_coordinates(mu) + 1, lattice.side);
        lattice.forward(site, mu) = sub2ind(shape, ...
            forward_coordinates(1) + 1, forward_coordinates(2) + 1, ...
            forward_coordinates(3) + 1, forward_coordinates(4) + 1);

        backward_coordinates = coordinates(site, :);
        backward_coordinates(mu) = mod(backward_coordinates(mu) - 1, lattice.side);
        lattice.backward(site, mu) = sub2ind(shape, ...
            backward_coordinates(1) + 1, backward_coordinates(2) + 1, ...
            backward_coordinates(3) + 1, backward_coordinates(4) + 1);
    end
end

links = complex(zeros(3, 3, lattice.n_sites, lattice.n_directions));
for site = 1:lattice.n_sites
    for mu = 1:lattice.n_directions
        links(:, :, site, mu) = eye(3);
    end
end

warmup = max(10, round(0.2 * measurements));
total_sweeps = warmup + measurements;
history = zeros(measurements, 1);
accepted = 0;
proposals = 0;
stored = 0;
progress_stride = max(1, floor(total_sweeps / 20));

for sweep = 1:total_sweeps
    site_order = randperm(lattice.n_sites);
    for site_index = 1:lattice.n_sites
        site = site_order(site_index);
        direction_order = randperm(lattice.n_directions);

        for direction_index = 1:lattice.n_directions
            mu = direction_order(direction_index);
            before = local_action(links, lattice, site, mu);
            old_link = links(:, :, site, mu);
            proposal = expm(1i * step_size * random_traceless_hermitian());
            links(:, :, site, mu) = proposal * old_link;
            after = local_action(links, lattice, site, mu);
            delta_action = beta * (after - before);
            proposals = proposals + 1;

            if delta_action <= 0 || rand() < exp(-delta_action)
                accepted = accepted + 1;
            else
                links(:, :, site, mu) = old_link;
            end
        end
    end

    if sweep > warmup
        stored = stored + 1;
        history(stored) = mean(su3_plaquettes(links, lattice));
    end

    if ~isempty(progress_callback) && mod(sweep, progress_stride) == 0
        progress_callback(sweep, total_sweeps);
    end
end

final_plaquettes = su3_plaquettes(links, lattice);
acceptance = accepted / proposals;
end

function value = local_action(links, lattice, site, mu)
value = 0;
for nu = 1:lattice.n_directions
    if nu == mu
        continue;
    end

    previous_site = lattice.backward(site, nu);
    first = plaquette_value(links, lattice, site, mu, nu);
    second = plaquette_value(links, lattice, previous_site, mu, nu);
    value = value + (1 - first) + (1 - second);
end
end

function value = plaquette_value(links, lattice, site, mu, nu)
x_plus_mu = lattice.forward(site, mu);
x_plus_nu = lattice.forward(site, nu);
loop = links(:, :, site, mu) * links(:, :, x_plus_mu, nu) ...
    * links(:, :, x_plus_nu, mu)' * links(:, :, site, nu)';
value = real(trace(loop)) / 3;
end

function h = random_traceless_hermitian()
sample = randn(3) + 1i * randn(3);
h = (sample + sample') / 2;
h = h - (trace(h) / 3) * eye(3);
end
