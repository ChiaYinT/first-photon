function [n, p] = reconstruction_from_tof(s, l, distance)

n = nan(3,1);
p = nan(3,1);

s = s - repmat(l, 1, size(s,2));


A = zeros(size(s,2)-1,2);
b = zeros(size(s,2)-1,1);

f1 = (distance(1))^2 - norm(s(:,1))^2;
for i = 2:size(s,2),
    f2 = (distance(i))^2 - norm(s(:,i))^2;
    b(i-1,1) = f1 - f2; 
    
    A(i-1,:) = [s(1,i)-s(1,1) s(2,i)-s(2,1)]; 
end


n_tmp = A\b;

if f1 + n_tmp(1)*s(1,1) + n_tmp(2)*s(2,1) < 0,
    return;
end

tau = -sqrt(f1 + n_tmp(1)*s(1,1) + n_tmp(2)*s(2,1))/2;
nx = n_tmp(1)/4/tau;
ny = n_tmp(2)/4/tau;

if nx^2 + ny^2 <=1 
    n = [nx;ny;-sqrt(1-nx^2-ny^2)];
    p = l + s(:,1) + ((tau*n-s(:,1))'*n/((2*tau*n-s(:,1))'*n)) * (2*tau*n-s(:,1));
end
end