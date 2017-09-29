function [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option)

if isfield(option, 'z_direction')
    z_direction = option.z_direction;
else
    z_direction = 1;
end

pair_dist = dist(sensor);
neighbor_size = 9;

occupancy = ones(size(space_carving_Z));

distance_to_light = sqrt((space_carving_X - light(1)).^2 + (space_carving_Y - light(2)).^2 + (space_carving_Z - light(3)).^2);

for i = 1:size(sensor,2),
    distance_to_sensor = sqrt((space_carving_X - sensor(1,i)).^2 + (space_carving_Y - sensor(2,i)).^2 + (space_carving_Z - sensor(3,i)).^2);
    total_dist = distance_to_light + distance_to_sensor;
    [Y,I] = sort(pair_dist(:,i));
    group_idx = I(1:min(neighbor_size,length(I)));
    occupancy = occupancy.*(total_dist > min(distance(1,group_idx)));
end



depth_map = nan(size(space_carving_X,1),size(space_carving_X,2));
for i = 1:size(space_carving_X,1)
    for j = 1:size(space_carving_X,2),
        if z_direction == 1,
            depth_idx = find(occupancy(i,j,:)==1,1);
        else            
            depth_idx = find(occupancy(i,j,:)==1,1,'last');
        end
        if ~isempty(depth_idx)
            %depth_map(i,j) = space_carving_Z(i,j,max(1,depth_idx-1));
            depth_map(i,j) = space_carving_Z(i,j,depth_idx);
        end
    end
end


X = space_carving_X(1,:,1);
Y = space_carving_Y(:,1,1); 
end