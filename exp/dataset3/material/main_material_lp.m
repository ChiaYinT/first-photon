clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/MaterialCharacterization/';
first_photon_folder =  '../../../data/dataset3-first_photon/MaterialCharacterization/';
transient_folder = '../../../data/dataset3-transient_data/MaterialCharacterization/';


%test = 'SP_X_-625mm_24.4_90_Dt_3_1_2017_M1_168';
test = 'SP_X_770mm_16.8_90_Dt_3_1_2017_M1_168';


gt_file = [first_photon_gt_folder test '.mat'];
load(gt_file);



figure; hold on;
c = hsv(3);
for i = 1:3
    name = strrep(test, 'M1', ['M' num2str(i)]);
    file = [first_photon_folder name '.mat'];
    load(file);
    
    
    transient_file = [transient_folder name '.mat'];
    load(transient_file);
    
    light = vd(1,:)';
    
    dist = first_photon*bin_width*speed_of_light;
    sensor = vs';
    sensor = sensor(:,~isnan(dist));
    distance = dist(~isnan(dist))';
    
    
    
    
    option.z_direction = -1;
    
    option.neighbor_size = 5;
    option.neighbor_threshold = 0.2;
    option.space_carving_threshold = 0.03+0.05*sqrt(3);
    
    [space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-1:0.05:1, -0.5:0.05:0.5, -1:0.05:0);
    [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
    
    
    
    result_file = ['result-lp/' name '.mat'];
    
    if exist(result_file, 'file')
        load(result_file);
    else
        [n_lp, p_lp] = reconstruction_from_lp(sensor, light, distance, option);
        
        [idx] = filter_recovered_pt(sensor,p_lp);
        filtered_p = p_lp(:,idx);
        filtered_n = n_lp(:,idx);
        
        [space_carved_idx] = space_carving_check(X,Y,depth_map, filtered_p, option);
        reconstructed_p = filtered_p(:,space_carved_idx);
        reconstructed_n = filtered_n(:,space_carved_idx);
        
        save(result_file, 'n_lp', 'p_lp', 'filtered_p', 'filtered_n', 'reconstructed_p', 'reconstructed_n');
    end
    
    
    
    rmse(i) = sqrt(nanmean((gt_n'*(reconstructed_p-repmat(gt_p(:,1),1,size(reconstructed_p,2)))).^2));
    normal_error(i) = nanmean(acosd(gt_n'*reconstructed_n));
    
    plot3(reconstructed_p(2,:),reconstructed_p(3,:),reconstructed_p(1,:), '.', 'color', c(i,:));
    
    
end

plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
plot3(light(2), light(3), light(1), 'kx');

fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);
axis equal;
hold off;
view(-38,44);
set(gca, 'fontsize', 28);
