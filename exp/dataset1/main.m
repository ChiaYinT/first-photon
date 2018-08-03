clear; clc; close all; 

addpath('../../util');
addpath('../../reconstruction');

load '../../data/dataset1/dataset.mat';
load 'results/first_photon_idx';
s = dataset.laserPos';
light = dataset.cameraPos';

img_first_photon = ones(size(dataset.data,1), dataset.t,3);
for i = 1:size(dataset.data,1),
    fprintf('i=%d\n', i);
        idx = first_photon_idx(i,1);
        if isempty(idx),
            break;
        end
        img_first_photon(i, idx:idx+150,:) = repmat(reshape([1 0 0],1,1,3),1,151);
end

figure; imagesc(img_first_photon(:,1:8000,:));
set(gca, 'FontSize', 18);


first_photon_dist = zeros(1,size(dataset.laserPos,1));
offset = zeros(1, size(dataset.laserPos,1));
for i = 1:size(dataset.laserPos,1),
    first_photon_dist(1,i) = first_photon_idx(i,1) * dataset.deltat + dataset.t0;
    offset(1,i) = norm(dataset.laserOrigin - dataset.laserPos(i,:)) + norm(dataset.cameraOrigin - dataset.cameraPos);
end
distance = first_photon_dist - offset;

figure; 
plot3(s(1,:), s(2,:), distance, 'b.');


option = [];
[space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-120:2:70, -20:2:70, 0:2:140);
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


figure;
plot3(reconstructed_p(1,:), reconstructed_p(2,:), reconstructed_p(3,:), 'b.');
zlim([0 90]);
axis equal
save('results/reconstruction_first_photon', 'reconstructed_p', 'reconstructed_n');


