clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/MultiObject/';
first_photon_folder = strrep(first_photon_gt_folder, 'gt', 'first_photon');
transient_folder = strrep(first_photon_gt_folder, 'gt', 'transient_data');

output_folder = 'result/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


option.z_direction = -1;

option.neighbor_size = 9;
option.neighbor_threshold = 0.1;
option.space_carving_threshold = 0.03+0.05*sqrt(3);

[space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-1:0.05:1, -0.5:0.05:0.5, -1:0.05:0);


file = dir(first_photon_gt_folder);
for f = 4
    if length(file(f,1).name)>2
        name = file(f,1).name;
        name
        gt_file = [first_photon_gt_folder name];
        load(gt_file);
        
        first_photon_file = [first_photon_folder name];
        load(first_photon_file);
        
        transient_file = [transient_folder name];
        load(transient_file);
        
        distance = min(first_photon,[],2)*bin_width*speed_of_light;
        sensor = vs(~isnan(distance),:)';
        light =  vd(1,:)';
        distance = distance(~isnan(distance))';
        [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
        
        
        
        result_file = [output_folder name];
        
        if exist(result_file, 'file')
            load(result_file);
        else
            
            reconstructed_p = [];
            reconstructed_n = [];
            for item = 1:size(first_photon,2)
                
                distance = first_photon(:,item)*bin_width*speed_of_light;
                sensor = vs(~isnan(distance),:)';
                light =  vd(1,:)';
                distance = distance(~isnan(distance))';
                
                [recovered_n_lp_tmp, recovered_p_lp_tmp] = reconstruction_from_lp(sensor, light, distance, option);
                
                [space_carved_idx] = space_carving_check(X,Y,depth_map, recovered_p_lp_tmp, option);
                
                recovered_p_lp_tmp = recovered_p_lp_tmp(:,space_carved_idx);
                recovered_n_lp_tmp = recovered_n_lp_tmp(:,space_carved_idx);
                
                
                reconstructed_p = [reconstructed_p recovered_p_lp_tmp];
                reconstructed_n = [reconstructed_n recovered_n_lp_tmp];
                
                
            end
            
            save(result_file,  'reconstructed_p', 'reconstructed_n');
        end
        
        
        
        figure; hold on;
        for item = 1:size(first_photon,2)
            plot(gt_first_photon(size(first_photon,1)*(item-1)+1:item*size(first_photon,1)), 'r'); 
            plot(first_photon(:,item), 'b');
        end
        
        sensor = vs';
        light =  vd(1,:)';
        
        figure; hold on;
        plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
        plot3(light(2), light(3), light(1), 'kx');
        plot3(gt_point(2,:),gt_point(3,:),gt_point(1,:), 'g.');
        
        for item = 1:size(first_photon,2)
            
            gt_c = c(:,item);
            gt_r = r(:,item);
            
            [sphere_X,sphere_Y,sphere_Z] = sphere;
            sphere_X = gt_r*sphere_X + gt_c(1);
            sphere_Y = gt_r*sphere_Y + gt_c(2);
            sphere_Z = gt_r*sphere_Z + gt_c(3);
            
            
            h = surf(sphere_Y,sphere_Z,sphere_X); hold on;
            set(h, 'FaceColor', [0.8 0.8 0.8]);
        end
        plot3(reconstructed_p(2,:),reconstructed_p(3,:),reconstructed_p(1,:), 'r.');
        axis equal;
        hold off;
        view(-38,44);
        set(gca, 'fontsize', 28);
        
        
        
        err = ones(1,size(reconstructed_p,2))*realmax;
        norm_err = nan(1,size(reconstructed_p,2));

        for item = 1:size(c,2)
        
            gt_c = c(:,item);
            gt_r = r(:,item);
            
            [sphere_X,sphere_Y,sphere_Z] = sphere;
            sphere_X = gt_r*sphere_X + gt_c(1);
            sphere_Y = gt_r*sphere_Y + gt_c(2);
            sphere_Z = gt_r*sphere_Z + gt_c(3);
            
            
            for j = 1:size(reconstructed_p,2)
                v = reconstructed_p(:,j) - gt_c;
                d = norm(v);
                tmp_err = abs(d - gt_r);
                if tmp_err < err(j)
                    err(j) = tmp_err;
                    v = v/d;

                    norm_err(j) = acosd(abs(reconstructed_n(:,j)'*v));
                end
            end
        end
        %rmse(f) = sqrt(err*err'/length(err));
        rmse(f) = sum(err)/length(err);
        rmse_normal(f) = sum(norm_err)/length(err);
        
        
    end
end

filename = 'result/quantitative';
save(filename, 'rmse','rmse_normal');
