function [E_p, E_n] = calc_error(p,n,o,r)
E_p = nan(1, size(p,2));
E_n = nan(1, size(p,2));

for i = 1:size(p,2),
    v = p(:,i) - o;
    E_p(i) = abs(norm(v) - r);
    E_n(i) = acosd(n(:,i)'*v/norm(v));
end

E_p = nanmean(E_p);
E_n = nanmean(E_n);
end