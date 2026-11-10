function [c, theta] = xeno_reaction(c, theta, h, capacity, kon, koff)
%XENO_REACTION Reacao local conservativa, Langmuir por Euler implicito.
% c + capacity*theta permanece constante em cada volume de controle.
validateattributes(c, {'double'}, {'real','finite','nonnegative'});
validateattributes(theta, {'double'}, {'real','finite','>=',0,'<=',1,'size',size(c)});
validateattributes(h, {'double'}, {'scalar','finite','nonnegative'});
validateattributes(capacity, {'double'}, {'scalar','finite','nonnegative'});
validateattributes(kon, {'double'}, {'scalar','finite','nonnegative'});
validateattributes(koff, {'double'}, {'scalar','finite','nonnegative'});
mass = c + capacity*theta;
a = h*kon*capacity;
b = 1 + h*kon*(mass+capacity) + h*koff;
d = theta + h*kon*mass;
% Raiz menor da quadratica, sem subtrair numeros quase iguais.
theta = 2*d ./ (b + sqrt(max(b.^2 - 4*a*d, 0)));
c = mass - capacity*theta;
assert(all(c(:) > -1e-12) && all(theta(:) < 1+1e-12));
c = max(c, 0); theta = min(max(theta, 0), 1);
end
