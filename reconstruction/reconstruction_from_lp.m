function [n, p] = reconstruction_from_lp(sensor, light, distance, option)

if isfield(option,'neighbor_size')
    neighbor_size = option.neighbor_size;
else
    neighbor_size = 3;
end

if isfield(option,'neighbor_threshold')
    neighbor_threshold = option.neighbor_threshold;
else
    neighbor_threshold = realmax;
end

if ~isfield(option, 'z_direction'),
     option.z_direction = 1;
end

pair_dist = dist(sensor);
n = nan(3,size(sensor,2));
p = nan(3,size(sensor,2));
[Y,I] = min(distance);
option.l0 = sensor(:,I);
option.l0(3) = option.z_direction*Y;


for i = 1:size(sensor,2),
    [Y,I] = sort(pair_dist(:,i));
    I(Y>neighbor_threshold) = [];
    group_idx = I(1:min(neighbor_size, length(I)));
    if length(group_idx) < 3,
        continue;
    end
    
    [n(:,i), p(:,i)] = reconstruction_from_optimization(sensor(:,group_idx), light, distance(1,group_idx), option);
    
    l0 = find_mirror_position(light, n(:,i), p(:,i));
end


end
