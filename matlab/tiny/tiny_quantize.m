function q = tiny_quantize(m, calibration_C)
%TINY_QUANTIZE INT8 simetrico, ativacoes INT8, bias e MAC INT32.
[~,~,hidden]=tiny_fp32(m,calibration_C);
q.input_scale=2/127; % dominio numerico representavel: aproximadamente 10..90 C
q.hidden_scale=max(double(hidden),[],'all')*1.10/127;
q.w1_scale=max(abs(double(m.W1)),[],'all')/127;
q.w2_scale=max(abs(double(m.W2)),[],'all')/127;
q.W1=int8(round(double(m.W1)/q.w1_scale));
q.W2=int8(round(double(m.W2)/q.w2_scale));
q.b1=int32(round(double(m.b1)/(q.input_scale*q.w1_scale)));
q.b2=int32(round(double(m.b2)/(q.hidden_scale*q.w2_scale)));
q.multiplier=int64(round(q.input_scale*q.w1_scale/q.hidden_scale*2^30));
q.shift=30;
q.mean_C=50; q.scale_C=20;
q.parameters=842;
q.payload_bytes=numel(q.W1)+numel(q.W2)+4*(numel(q.b1)+numel(q.b2));
q.activation_policy='out-of-domain input is flagged; no safety assertion';
tiny_validate_int8(q);
end
