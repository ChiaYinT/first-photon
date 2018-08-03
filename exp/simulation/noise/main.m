clear; clc; close all;
tic;
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
neighbor = 5:5:15;

output_folder = 'recovery/';
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end


average_tof_error = nan(size(simulation,2),size(neighbor,2));
E_p = nan(size(simulation,2),size(neighbor,2));
E_n = nan(size(simulation,2),size(neighbor,2));

for sim_it = 1:size(simulation,2),
    num_simulation = simulation(sim_it);
    idx = randperm(size(first_photon_iter,2), num_simulation);
    for neighbor_it = 1 : size(neighbor,2),
        fprintf('%d %d\n', sim_it, neighbor_it);
        num_neighbor = neighbor(neighbor_it);
        output_filename = [output_folder date_folder '_' num2str(num_simulation) '_' num2str(num_neighbor) '.mat'];
        if ~exist(output_filename,'file')
            first_photon = min(first_photon_iter(:,idx), [], 2)';
            rendered_tof = first_photon*exposure;
            average_tof_error(sim_it, neighbor_it) = nanmean(rendered_tof - tof_gt);
            discard_idx = isnan(rendered_tof);
            distance = rendered_tof*speed_of_light;
            distance = distance(1,discard_idx==0);
            sensor = sensor0(:,discard_idx ==0);
            [space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-5:0.1:2, -5:0.1:5,  0:0.05:min(distance));
            option.neighbor_size = num_neighbor;
            option.space_carving_threshold = 0.1*sqrt(3);
            [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
            [n, p] = reconstruction_from_lp(sensor, light, distance, option);
            
            [filter_idx] = filter_recovered_pt(sensor,p);
            filtered_p = p(:,filter_idx);
            filtered_n = n(:,filter_idx);
            
            [space_carved_idx] = space_carving_check(space_carving_X(1,:,1),space_carving_Y(:,1,1),depth_map, filtered_p, exposure*speed_of_light);
            
            recovered_p = filtered_p(:,space_carved_idx);
            recovered_n = filtered_n(:,space_carved_idx);
            save(output_filename, 'recovered_p', 'recovered_n', 'depth_map');
        else
            load(output_filename);
        end
        
        [E_p(sim_it, neighbor_it), E_n(sim_it, neighbor_it)] = calc_error(recovered_p,recovered_n,sphere_c,sphere_r);
        
    end
end

error_file = ['error/' date_folder];
save(error_file, 'average_tof_error', 'E_p', 'E_n');

figure; hold on;
c = hsv(size(E_p,2) + 1);
for i = 1:size(E_p,2)
    plot(E_p(:,i), 'color', c(i,:));
end
figure; hold on;
for i = 1:size(E_n,2)
    plot(E_n(:,i), 'color', c(i,:));
end


error_file = ['error-quadratic/' date_folder];
load(error_file);
figure(1); plot(E_p, 'color', c(i+1,:));
figure(2); plot(E_n, 'color', c(i+1,:));

toc;