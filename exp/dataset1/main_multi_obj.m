clear; clc; close all;

addpath('../../reconstruction');

load 'results/problem_cluster';

[space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-120:2:70, -20:2:70, 0:2:140);

distance_plane = distance;
s0 = s;
plane_color = hsv(size(distance_plane,1));
plane_p = cell(size(distance_plane,1),1);
plane_n = cell(size(distance_plane,1),1);
figure; hold on;
for plane_it = 1:size(distance_plane,1),
    fprintf('%d\n', plane_it);
    distance = distance_plane(plane_it,:);
    
    
    measurement_idx = ~isnan(distance);
    s = s0(:, measurement_idx);
    distance = distance(measurement_idx);
    
    option = [];
    [X,Y,depth_map] = space_carving(light,s,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
    
    option.neighbor_size = 5;
    option.neighbor_threshold = 30;
    [n, p] = reconstruction_from_lp(s, light, distance, option);
    
    
    [idx] = filter_recovered_pt(s,p);
    filtered_p = p(:,idx);
    filtered_n = n(:,idx);
    
    option.space_carving_threshold = 3*sqrt(8);
    [space_carved_idx] = space_carving_check(X,Y,depth_map, filtered_p, option);
    reconstructed_p = filtered_p(:,space_carved_idx);
    reconstructed_n = filtered_n(:,space_carved_idx);

    plane_p{plane_it,1} = reconstructed_p;
    plane_n{plane_it,1} = reconstructed_n;
    
    plot3(reconstructed_p(1,:), reconstructed_p(2,:), reconstructed_p(3,:), '.', 'color', plane_color(plane_it,:));
    clear n;
    clear p;
end


zlim([0 130]);
axis equal


save('results/reconstruction_first_photon_plane_cluster', 'plane_p', 'plane_n');


