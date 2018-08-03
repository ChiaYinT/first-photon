clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_folder =  '../../../data/dataset3-first_photon/MultiObject/';
transient_folder = strrep(first_photon_folder, 'first_photon', 'transient_data');
first_photon_gt_folder = strrep(first_photon_folder, 'first_photon', 'gt');

output_folder = 'result/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

[space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-1:0.05:1, -0.5:0.05:0.5, -1:0.05:0);

file = dir(first_photon_folder);
for f = 5:size(file,1)
    if length(file(f,1).name)>2
        name = file(f,1).name;
        name
        gt_file = [first_photon_gt_folder name];
        load(gt_file);
        
        first_photon_file = ['result-cluster/' name];
        load(first_photon_file);
        
        
        transient_file = [transient_folder name];
        load(transient_file);
        
        option.z_direction = -1;
        option.neighbor_size = 9;
        option.neighbor_threshold = 0.1;
        option.space_carving_threshold = 0.03+0.05*sqrt(3);
        
        light = vd(1,:)';
        dist = first_photon_label(:,1)*bin_width*speed_of_light;
        sensor = vs';
        sensor = sensor(:,~isnan(dist));
        distance = dist(~isnan(dist))';
        
        [space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-1:0.05:1, -0.5:0.05:0.5, -1:0.05:0);
        
        [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
        
        
        
        result_file = [output_folder name];
        
        if exist(result_file, 'file')
            load(result_file);
        else
            
            distance_all = first_photon_label*bin_width*speed_of_light;
            
            
            item_num = size(first_photon_label,2);
            plane_p = cell(item_num,1);
            plane_n = cell(item_num,1);
            
            for item = 1:item_num
                distance = distance_all(:,item);
                
                sensor = vs';
                sensor = sensor(:,~isnan(distance));
                light =  vd(1,:)';
                distance = distance(~isnan(distance))';
                
                [n_lp, p_lp] = reconstruction_from_lp(sensor, light, distance, option);
                
                [idx] = filter_recovered_pt(sensor,p_lp);
                filtered_p = p_lp(:,idx);
                filtered_n = n_lp(:,idx);
                
                [space_carved_idx] = space_carving_check(X,Y,depth_map, filtered_p, option);
                reconstructed_p = filtered_p(:,space_carved_idx);
                reconstructed_n = filtered_n(:,space_carved_idx);
                
                plane_p{item,1}  = reconstructed_p;
                plane_n{item,1} = reconstructed_n;
                
            end
            
            save(result_file, 'plane_p', 'plane_n');
        end
        
        
        sensor = vs';
        light =  vd(1,:)';
        
        figure; hold on;
        plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
        plot3(light(2), light(3), light(1), 'kx');
        
        
        recovered_pt = [];
        recovered_normal = [];
        for item = 1:size(plane_p)
            reconstructed_p = plane_p{item,1};
            plot3(reconstructed_p(2,:),reconstructed_p(3,:),reconstructed_p(1,:), 'r.');
            recovered_pt = [recovered_pt reconstructed_p];
            recovered_normal = [recovered_normal  plane_n{item,1}];
        end
        
        recovered_pt(:,isnan(recovered_pt(1,:))) = [];
        recovered_normal(:,isnan(recovered_normal(1,:))) = [];
        
        err = realmax*ones(1,size(recovered_pt,2));
        err_normal = nan(1,size(recovered_pt,2));
        
        for item = 1:size(p_collection,1)
            p = p_collection{item,1};
            gt_p = gt_p_collection{item,1};
            n = gt_n_collection{item,1};
            gt_point = gt_point_collection{item,1};
            fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);
            plot3(gt_point(2,:),gt_point(3,:),gt_point(1,:), 'g.');
            
            
            for i = 1:size(recovered_pt,2)
                err_tmp  = abs(n'*(recovered_pt(:,i) - gt_p));
                if (err_tmp < err(i))
                    err(i) = err_tmp;
                    err_normal(i) = acosd(abs(n'*recovered_normal(:,i)));
                end
                
            end
        end
        
        error_result(f) = mean(err);
        err_normal_result(f) = mean(err_normal);
        axis equal;
        hold off;
        view(-38,44);
        set(gca, 'fontsize', 28);
        
    end
end

