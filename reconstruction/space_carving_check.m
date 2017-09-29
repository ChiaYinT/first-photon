function [space_carved_idx] = space_carving_check(X,Y,depth_map, p, option)
if isfield(option, 'space_carving_threshold'),
    threshold = option.space_carving_threshold;
else
    threshold = 0.05;
end

if isfield(option, 'z_direction')
    z_direction = option.z_direction;
else
    z_direction = 1;
end
space_carved_idx = 1:size(p,2);
for i = size(p,2): -1:1,
    x = p(1,i);
    y = p(2,i);
    z = p(3,i);
    
    [val,Ix] = min(abs(X-x));
    [val,Iy] = min(abs(Y-y));
    if depth_map(Iy,Ix) == 0
        if z_direction == 1 && z < 0 || z_direction == -1 && z > 0
            space_carved_idx(i) = [];
        end
        continue;
    end
    
    if z_direction == 1,
        if z < depth_map(Iy,Ix) - threshold ,
            space_carved_idx(i) = [];
        end
    else
        if z > depth_map(Iy,Ix) + threshold,
            space_carved_idx(i) = [];
        end
    end
    
end

end
