function [strain, capacitance_F] = xeno_mechanics(previous, pressure_Pa, h, p)
%XENO_MECHANICS Kelvin-Voigt, pressao constante durante h; area fixa.
validateattributes(pressure_Pa, {'double'}, {'scalar','real','finite','nonnegative'});
validateattributes(h, {'double'}, {'scalar','finite','nonnegative'});
assert(p.young_Pa > 0 && p.viscosity_Pa_s > 0);
equilibrium = pressure_Pa/p.young_Pa;
assert(equilibrium <= 0.1, 'Fora da hipotese de pequena deformacao (10%%).');
strain = equilibrium + (previous-equilibrium)*exp(-h*p.young_Pa/p.viscosity_Pa_s);
assert(strain >= 0 && strain < 1);
c0 = 8.8541878128e-12*p.relative_permittivity*p.electrode_area_m2/p.dielectric_thickness_m;
capacitance_F = c0/(1-strain);
end
