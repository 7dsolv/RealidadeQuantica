function [difference, before, after] = validate_su3_gauge(links, lattice)
%VALIDATE_SU3_GAUGE Compare plaquettes before and after a local gauge change.

before = su3_plaquettes(links, lattice);
n_sites = lattice.n_sites;
gauge = complex(zeros(3, 3, n_sites));
for site = 1:n_sites
    gauge(:, :, site) = su3_random_haar();
end

transformed = complex(zeros(size(links)));
for site = 1:n_sites
    for mu = 1:lattice.n_directions
        next_site = lattice.forward(site, mu);
        transformed(:, :, site, mu) = gauge(:, :, site) ...
            * links(:, :, site, mu) * gauge(:, :, next_site)';
    end
end

after = su3_plaquettes(transformed, lattice);
difference = max(abs(before - after));
end
