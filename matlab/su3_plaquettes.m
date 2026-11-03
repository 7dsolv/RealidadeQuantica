function values = su3_plaquettes(links, lattice)
%SU3_PLAQUETTES Measure ReTr(U_p)/3 for every plaquette in the lattice.

n_sites = lattice.n_sites;
n_directions = lattice.n_directions;
n_plaquettes = n_sites * n_directions * (n_directions - 1) / 2;
values = zeros(n_plaquettes, 1);
cursor = 0;

for site = 1:n_sites
    for mu = 1:n_directions
        for nu = (mu + 1):n_directions
            cursor = cursor + 1;
            x_plus_mu = lattice.forward(site, mu);
            x_plus_nu = lattice.forward(site, nu);

            u_mu_x = links(:, :, site, mu);
            u_nu_x_plus_mu = links(:, :, x_plus_mu, nu);
            u_mu_x_plus_nu = links(:, :, x_plus_nu, mu);
            u_nu_x = links(:, :, site, nu);

            loop = u_mu_x * u_nu_x_plus_mu ...
                * u_mu_x_plus_nu' * u_nu_x';
            values(cursor) = real(trace(loop)) / 3;
        end
    end
end
end
