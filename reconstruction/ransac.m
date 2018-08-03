function [best_fit, best_err, best_inlier] = ransac(light, sensor, distance, iteration_num, threshold, inlier_num,sensor_dist_threshold)
sensor = sensor - repmat(light,1,size(sensor,2));
sensor_dist = dist(sensor);
close_by_sensor = sensor_dist <= sensor_dist_threshold;
close_by_sensor = close_by_sensor - diag(diag(close_by_sensor));

n = 4;
best_fit = [];
best_err = realmax;
best_inlier = [];
random_sample_flag = 1;

combination_num = nchoosek(size(sensor,2),n);

if iteration_num >= combination_num,
    iteration_num = combination_num;
    random_sample_flag = 0;
    C = nchoosek(1:size(sensor,2),n);
end

for iteration = 1:iteration_num,
    if random_sample_flag == 1,
        center_idx = randsample(size(sensor,2), 1);
        close_sensor = find(close_by_sensor(:,center_idx)==1);
        
        if length(close_sensor) < n-1
            continue;
        end
        random_selected_idx = randsample(length(close_sensor), n-1);
        maybe_inlier = [center_idx close_sensor(random_selected_idx,1)'];
        
        maybe_inlier_iter = 1;
        %maybe_inlier = randsample(size(sensor,2), n);
        while line_check(sensor(:,maybe_inlier)) == 0 && maybe_inlier_iter < 100,
            random_selected_idx = randsample(length(close_sensor), n-1);
            maybe_inlier = [center_idx close_sensor(random_selected_idx,1)'];

            %maybe_inlier = randsample(size(sensor,2), n);
            maybe_inlier_iter = maybe_inlier_iter + 1;
        end
    else
        maybe_inlier = C(iteration,:);
        if line_check(sensor(:,maybe_inlier)) == 0
            continue;
        end
    end
    
    [maybe_l] = quadratic_fit(sensor(:,maybe_inlier), distance(1,maybe_inlier));
    
    if sum(isnan(maybe_l))==6,
        continue;
    end
    
    if isnan(maybe_l(1))
        d1 = norm(maybe_l(4:6));
        d2 = sqrt((sensor(1,:) - maybe_l(4)).^2 + (sensor(2,:) - maybe_l(5)).^2  + maybe_l(6)^2);
        dist_est = d1+d2;
    else
        dist_est = sqrt((sensor(1,:) - maybe_l(1)).^2 + (sensor(2,:) - maybe_l(2)).^2  + maybe_l(3)^2);
    end
    
    also_inlier = find(abs(dist_est-distance) < threshold);

    if sum(abs(dist_est(maybe_inlier) - distance(maybe_inlier)) < threshold) ~= n
        continue;
    end
   
    
    
    if length(also_inlier) > inlier_num,
%         flag = zeros(1,size(sensor,2));
%         
%         for i = 1:size(also_inlier,2)
%             flag(sensor_dist(:,also_inlier(i))<= sensor_dist_threshold) = 1;
%         end
        

        %also_inlier = find(flag==1);
        
        [better_l] = quadratic_fit(sensor(:,also_inlier), distance(1,also_inlier));
        if sum(isnan(better_l)) == 6
            continue;
        end
        
        if isnan(better_l(1))
            d1 = norm(better_l(3:6));
            d2 = sqrt((sensor(1,also_inlier) - better_l(1)).^2 + (sensor(2,also_inlier) - better_l(2)).^2  + better_l(3)^2);
            mse = norm(d1 + d2 - distance(1,also_inlier))^2/length(also_inlier)^2;
        else
            dist_est = sqrt((sensor(1,also_inlier) - better_l(1)).^2 + (sensor(2,also_inlier) - better_l(2)).^2  + better_l(3)^2);
            mse = norm(dist_est - distance(1,also_inlier))^2/length(also_inlier)^2;
        end
        
        if mse < best_err,
            best_fit = better_l + repmat(light,2,1);
            best_err = mse;
            best_inlier = also_inlier;
%             f1 = plot(sensor(1,also_inlier)+light(1), sensor(2,also_inlier)+light(2), 'bo');
%             f2 = plot(sensor(1,maybe_inlier)+light(1), sensor(2,maybe_inlier)+light(2), 'b.');
        end
    end
%     if exist('f1', 'var')
%     delete(f1);
%     delete(f2);
%     end
end

end


function [l] = quadratic_fit(s, distance)

[l1, plane_err] = quadratic_fit_plane(s, distance);
l(1:3,1) = l1; 
[l2, corner_err] = quadratic_fit_corner(s,distance);
if corner_err < plane_err
    l(1:3,1) = nan(3,1);
    l(4:6,1) = l2;
else
    l(4:6,1) = nan(3,1);
end
end

function [l,err] = quadratic_fit_corner(sensor,distance)

A = zeros(size(sensor,2)-1, 3);
b = zeros(size(sensor,2)-1, 1);

for i = 2:size(sensor,2),
    A(i - 1,:) = 2*[sensor(1,i) - sensor(1,1), sensor(2,i) - sensor(2,1), distance(1) - distance(i)];
    b(i-1) = -distance(i)^2 + distance(1)^2 + sensor(1,i)^2 - sensor(1,1)^2 + sensor(2,i)^2 - sensor(2,1)^2;
end

x = A\b;
tmp = x(1)^2 + x(2)^2;
if tmp > x(3)^2,
    l = nan(3,1);
    err = nan;
    return
end

z = sqrt(x(3)^2 - tmp);
l = [x(1:2); z];
err = 0;
d1 = x(3);
for i = 1:size(sensor,2),
    err = err + (d1 + norm(l-sensor(:,i)) - distance(i))^2;
end

end

function [l,err] = quadratic_fit_plane(s,distance)
A = zeros(size(s,2)-1,2);
b = zeros(size(s,2)-1,1);

for j = 2:size(s,2),
    A(j-1,:) = [s(1,1)-s(1,j) s(2,1)-s(2,j)];
    b(j-1,1) = distance(1)^2 - distance(j)^2 - s(1,1)^2 + s(1,j)^2 - s(2,1)^2 + s(2,j)^2;
end

A = A*(-2);

l = A\b;
for i = 1:size(s,2);
    z2 = distance(i)^2 - (s(1,i)-l(1))^2 - (s(2,i)-l(2))^2;
    if z2 >=0
        break;
    end
end



if z2 < 0,
    z2 = 0;
end
l(3) = sqrt(z2);

err = 0;
for i = 1:size(s,2),
    err = err + (norm(l-s(:,i)) - distance(i))^2;
end


end


function [check] = line_check(sensor)
threshold = 0.01;
if norm(cross(sensor(:,2) - sensor(:,1), sensor(:,3) - sensor(:,1))) < threshold
    check = 0;
elseif norm(cross(sensor(:,4) - sensor(:,1), sensor(:,3) - sensor(:,1))) < threshold
    check = 0;
elseif (cross(sensor(:,4) - sensor(:,1), sensor(:,2) - sensor(:,1))) < threshold
    check = 0;
elseif norm(cross(sensor(:,4) - sensor(:,2), sensor(:,3) - sensor(:,2))) < threshold
    check = 0;
else
    check = 1;
end
end