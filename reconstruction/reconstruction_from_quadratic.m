function [n, p, mirrored_l] = reconstruction_from_quadratic(s, l, distance)


%function [l] = quadratic_fit(s, distance)
s = s - repmat(l,1,size(s,2));

A = zeros(size(s,2)-1,2);
b = zeros(size(s,2)-1,1);

i = 1;
for j = i+1:size(s,2),
    A(j-1,:) = [s(1,1)-s(1,j) s(2,1)-s(2,j)];
    b(j-1,1) = distance(1)^2 - distance(j)^2 - s(1,1)^2 + s(1,j)^2 - s(2,1)^2 + s(2,j)^2;
end

A = A*(-2);

mirrored_l = A\b;
z2 = distance(1)^2 - (s(1,1)-l(1))^2 - (s(2,1)-l(2))^2;

if z2 < 0,
    mirrored_l = nan(3,1);
else
    mirrored_l(3) = sqrt(z2);
end

n = mirrored_l/norm(mirrored_l);
p = mirrored_l/2 + l;


end
