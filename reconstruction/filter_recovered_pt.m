function [idx] = filter_recovered_pt(sensor,p)

idx = 1:size(sensor,2);
neighbor_num = 5;
scale = sqrt(2)*sqrt(8);
pair_dist = dist(sensor);
pair_recovered_dist = dist(p);
for i = size(sensor,2):-1:1,
    [Y,I] = sort(pair_dist(:,i));
    sensor_distance = Y(1:min(neighbor_num, length(Y)));

    recovered_dist = pair_recovered_dist(I(1:min(neighbor_num, length(I))),i);
    if sum(recovered_dist > scale*sensor_distance) > neighbor_num/2
        idx(i) = [];
    end
end

end
