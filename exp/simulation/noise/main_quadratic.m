clear; clc; close all;
tic;

warning off;

addpath('../../../reconstruction');
addpath('../../../util/');

date_folder = '0127';

load(['../../../simulation/setup/' date_folder]);
load(['../../../simulation/first_photon_iter/' date_folder]);
load('ground_truth_1116');

sensor0 = sensor;
speed_of_light = 299792458;
show_geometry_setup = 1;
test_setup = 0;

exposure = pinhole_camera.exposure*10^-12;

simulation = 4:4:32;

output_folder = 'recovery-quadratic/';
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end


average_tof_error = nan(size(simulation,2),1);
E_p = nan(size(simulation,2),1);
E_n = nan(size(simulation,2),1);

for sim_it = 1:size(simulation,2),
    num_simulation = simulation(sim_it);
    idx = randperm(size(first_photon_iter,2), num_simulation);
    
    
    fprintf('%d\n', sim_it);
    output_filename = [output_folder date_folder '_' num2str(num_simulation) '.mat'];
    if ~exist(output_filename,'file')
        first_photon = min(first_photon_iter(:,idx), [], 2)';
        rendered_tof = first_photon*exposure;
        average_tof_error(sim_it, 1) = nanmean(rendered_tof - tof_gt);
        discard_idx = isnan(rendered_tof);
        distance = rendered_tof*speed_of_light;
        distance = distance(1,discard_idx==0);
        sensor = sensor0(:,discard_idx ==0);
        [space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-5:0.1:2, -5:0.1:5,  0:0.05:min(distance));
        option.neighbor_size = 5;
        option.space_carving_threshold = 0.1*sqrt(3);
        [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
        
        
        
        sensor_idx = 1:length(distance);
        recover_threshold = 0.0005;
        inlier_num = 5;
        ransac_inlier_num = 10;
        ransac_iteration = 1;
        recovered_pt = [];
        recovered_normal = [];
        fail_model = 1;
        flag = 1;
        while length(sensor_idx) > inlier_num && ransac_iteration < size(first_photon_iter,1)/ransac_inlier_num && flag == 1,
            [best_fit, best_err, best_inlier] = ransac(light, sensor(:,sensor_idx), distance(1,sensor_idx), 10000, recover_threshold, ransac_inlier_num, 0.5);
            
            if isempty(best_fit)
                if fail_model < 10,
                    fail_model = fail_model + 1;
                    continue;
                else
                    flag = 0;
                    continue;
                end
            end
            
            if isnan(best_fit(1))
                pt = best_fit(4:6);
                normal = nan(3,1);
            else
                best_inlier_idx = sensor_idx(1,best_inlier);
                [pt, normal] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier_idx));
            end
            
            
            for i = length(best_inlier):-1:1,
                sensor_idx(best_inlier(i)) = [];
            end
            recovered_pt  = [recovered_pt pt];
            recovered_normal = [recovered_normal repmat(normal,1,size(pt,2))];
            ransac_iteration = ransac_iteration + 1;
            
            fprintf('%d\n', ransac_iteration);
        end
        
        
        [space_carved_idx] = space_carving_check(space_carving_X(1,:,1),space_carving_Y(:,1,1),depth_map, recovered_pt, exposure*speed_of_light);
        
        recovered_pt = recovered_pt(:,space_carved_idx);
        recovered_normal = recovered_normal(:,space_carved_idx);
        
        
        save(output_filename, 'recovered_pt', 'recovered_normal');
        
    else
        load(output_filename);
    end
    
    [E_p(sim_it, 1), E_n(sim_it, 1)] = calc_error(recovered_pt,recovered_normal,sphere_c,sphere_r);
    E_p
    E_n
end

error_file = ['error-quadratic/' date_folder];
save(error_file, 'average_tof_error', 'E_p', 'E_n');

figure; hold on;
c = hsv(size(E_p,2));
for i = 1:size(E_p,2)
    plot(E_p(:,i), 'color', c(i,:));
end
figure; hold on;
for i = 1:size(E_n,2)
    plot(E_n(:,i), 'color', c(i,:));
end

toc;