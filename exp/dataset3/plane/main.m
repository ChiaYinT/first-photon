clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/PlaneCharacterization/';
first_photon_folder = strrep(first_photon_gt_folder, 'gt', 'first_photon');
transient_folder = strrep(first_photon_gt_folder, 'gt', 'transient_data');

output_folder = 'result/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


file = dir(first_photon_gt_folder);
for f = 1:size(file,1)
    if length(file(f,1).name)>2
        name = file(f,1).name;
        name
        gt_file = [first_photon_gt_folder name];
        load(gt_file);
        
        first_photon_file = [first_photon_folder name];
        load(first_photon_file);
        
        transient_file = [transient_folder name];
        load(transient_file);
        
        light = vd(1,:)';
        
        dist = first_photon*bin_width*speed_of_light;
        sensor = vs';
        sensor = sensor(:,~isnan(dist));
        distance = dist(~isnan(dist))';
        
        
        
        option.z_direction = -1;
        
        option.neighbor_size = 9;
        option.neighbor_threshold = 0.1;
        option.space_carving_threshold = 0.03+0.05*sqrt(3);
        
        [space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-1:0.05:1, -0.5:0.05:0.5, -1:0.05:0);
        [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
        
        
        result_file = [output_folder name];
        
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
        
        
        
        %rmse(f) = sqrt(nanmean((gt_n'*(reconstructed_p-repmat(gt_p(:,1),1,size(reconstructed_p,2)))).^2));
        rmse(f) = nanmean(abs(gt_n'*(reconstructed_p-repmat(gt_p(:,1),1,size(reconstructed_p,2)))));
        rmse_normal(f) = nanmean(acosd(abs(gt_n'*reconstructed_n)));
        
        figure;
        plot(gt_first_photon, 'r'); hold on;
        plot(first_photon, 'b');
        
        
        
        figure; hold on;
        plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
        plot3(light(2), light(3), light(1), 'kx');
        plot3(gt_point(2,:),gt_point(3,:),gt_point(1,:), 'g.');

        fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);
        plot3(reconstructed_p(2,:),reconstructed_p(3,:),reconstructed_p(1,:), 'r.');
        axis equal;
        hold off;
        view(-38,44);
        set(gca, 'fontsize', 28);
        
    end
end

filename = 'result/quantitative';
save(filename, 'rmse','rmse_normal');
