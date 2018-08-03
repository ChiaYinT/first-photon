clear; clc; close all; 

addpath('../../util');
addpath('../../reconstruction');

load '../../data/dataset1/dataset.mat';
load 'results/first_photon_idx';
light = dataset.cameraPos';

data_cnt = 1;
img_first_photon = ones(size(dataset.data,1), dataset.t,3);

for i = 1:size(first_photon_idx,1)

    
    offset = norm(dataset.laserOrigin - dataset.laserPos(i,:)) + norm(dataset.cameraOrigin - dataset.cameraPos);

    for j = 1:size(first_photon_idx,2)
        if ~isnan(first_photon_idx(i,j))
            idx = first_photon_idx(i,j);
            img_first_photon(i, idx:idx+150,:) = repmat(reshape([1 0 0],1,1,3),1,151);

            s(:,data_cnt) = dataset.laserPos(i,:)';
            
            first_photon_dist = first_photon_idx(i,j) * dataset.deltat + dataset.t0;
            distance(data_cnt) =  first_photon_dist - offset;
  
            data_cnt = data_cnt + 1;
        end
        
    end
end


figure; imagesc(img_first_photon(:,1:8000,:));
set(gca, 'FontSize', 18);


figure; 
plot3(s(1,:), s(2,:), distance, 'b.');



g = figure; hold on;
h = figure; hold on;

sensor_idx = 1:size(s,2);

inlier_num = 4;
ransac_iteration = 1;
recovered_pt = cell(1);
recovered_normal = cell(1);
ransac_sensor =cell(1);
while length(sensor_idx) > inlier_num && ransac_iteration < 10,
    %[best_fit, best_err, best_inlier] = ransac(light, sensor, distance, iteration_num, threshold, inlier_num,sensor_dist_threshold)

    [best_fit, best_err, best_inlier] = ransac(light, s(:,sensor_idx), distance(1,sensor_idx), 5000, 3, 10, 50);
    
    if isempty(best_fit)
        break;
    end
    
    if isnan(best_fit(1))
        pt = best_fit(3:4,1);
        normal = nan(3,1);
    else
        best_inlier_idx = sensor_idx(1,best_inlier);
        [pt, normal] = find_pt(light, best_fit(1:3,1), s(:,best_inlier_idx));
    end
    
    figure(g);
    plot3(pt(1,:), pt(2,:), pt(3,:), 'b.');
    
    for i = length(best_inlier):-1:1,
        sensor_idx(best_inlier(i)) = [];
    end
    
    figure(h);
    plot3(s(1,best_inlier_idx),s(2,best_inlier_idx),s(3,best_inlier_idx), 'b.' );
    
    recovered_pt{ransac_iteration,1} = pt;
    recovered_normal{ransac_iteration,1} = normal;
    ransac_sensor{ransac_iteration,1} = best_inlier_idx;
    ransac_iteration = ransac_iteration + 1;
end

filename = 'results/reconstruction_quadratic';
save(filename, 'recovered_pt', 'recovered_normal');