function [best_fit, best_err, best_inlier] = ransac_quadratic(sensor, dist, iteration_num, threshold, inlier_num)
n = 3;
best_fit = [];
best_err = realmax;
best_inlier = [];
for iteration = 1:iteration_num,
    
    maybe_inlier = randsample(size(sensor,2), n);
    while line_check(sensor(:,maybe_inlier)) == 0,
        maybe_inlier = randsample(size(sensor,2), n);
    end
    
    [maybe_l] = quadratic_fit(sensor(:,maybe_inlier), dist(1,maybe_inlier));
    
    if isnan(maybe_l(1)),
        continue;
    end
    dist_est = sqrt((sensor(1,:) - maybe_l(1)).^2 + (sensor(2,:) - maybe_l(2)).^2  + maybe_l(3)^2);
    also_inlier = find(abs(dist_est-dist) < threshold);

%     if one_line(sensor(:,also_inlier)) == 1,
%         continue;
%     end
    
    if length(also_inlier) > inlier_num,
        [better_l] = quadratic_fit(sensor(:,also_inlier), dist(1,also_inlier));
        if isnan(better_l(1))
            continue;
        end
        dist_est = sqrt((sensor(1,also_inlier) - better_l(1)).^2 + (sensor(2,also_inlier) - better_l(2)).^2  + better_l(3)^2);
        mse = norm(dist_est - dist(1,also_inlier))/length(also_inlier);
        if mse < best_err,
            best_fit = better_l;
            best_err = mse;
            best_inlier = also_inlier;
        end
    end
end

end


function [l] = quadratic_fit(s, distance)

A = zeros(size(s,2)-1,2);
b = zeros(size(s,2)-1,1);

i = 1;
for j = i+1:size(s,2),
    A(j-1,:) = [s(1,1)-s(1,j) s(2,1)-s(2,j)];
    b(j-1,1) = distance(1)^2 - distance(j)^2 - s(1,1)^2 + s(1,j)^2 - s(2,1)^2 + s(2,j)^2;
end

A = A*(-2);

l = A\b;
z2 = distance(1)^2 - (s(1,1)-l(1))^2 - (s(2,1)-l(2))^2;

if z2 < 0,
    l = nan(3,1);
else
    l(3) = sqrt(z2);
end


end


function [check] = line_check(sensor)
threshold = 0.01;
if cross(sensor(:,2) - sensor(:,1), sensor(:,3) - sensor(:,1)) < threshold
    check = 0;
else
    check = 1;
end
end