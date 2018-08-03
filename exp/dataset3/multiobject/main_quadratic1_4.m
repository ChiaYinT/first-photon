clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_folder =  '../../../data/dataset3-first_photon/MultiObject/';
transient_folder = strrep(first_photon_folder, 'first_photon', 'transient_data');
first_photon_gt_folder = strrep(first_photon_folder, 'first_photon', 'gt');

output_folder = 'result-quadratic/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

file = dir(first_photon_folder);
for f = 5:size(file,1)
    if length(file(f,1).name)>2
        name = file(f,1).name;
        name
        gt_file = [first_photon_gt_folder name];
        load(gt_file);
        
        first_photon_file = [first_photon_folder name];
        load(first_photon_file);
        
        
        transient_file = [transient_folder name];
        load(transient_file);
        
        option.z_direction = -1;
        option.neighbor_size = 9;
        option.neighbor_threshold = 0.1;
        option.space_carving_threshold = 0.03+0.05*sqrt(3);
        
        light = vd(1,:)';
        dist = first_photon(:,1)*bin_width*speed_of_light;
        sensor = vs';
        sensor = sensor(:,~isnan(dist));
        distance = dist(~isnan(dist))';
        
        [space_carving_X, space_carving_Y, space_carving_Z] = meshgrid(-1:0.05:1, -0.5:0.05:0.5, -1:0.05:0);
        
        [X,Y,depth_map] = space_carving(light,sensor,distance,space_carving_X, space_carving_Y, space_carving_Z, option);
        
        
        
        result_file = [output_folder name];
        
        if exist(result_file, 'file')
            load(result_file);
        else
            item_num = size(first_photon,2);
            distance = first_photon(:)*bin_width*speed_of_light;
            sensor = repmat(vs', 1, item_num);
            sensor = sensor(:,~isnan(distance));
            light =  vd(1,:)';
            distance = distance(~isnan(distance))';
            
            
            sensor_idx = 1:length(distance);
            recover_threshold = 0.003;
            inlier_num = 4;
            ransac_iteration = 1;
            recovered_pt = [];
            recovered_normal = [];
            
            while length(sensor_idx) > inlier_num && ransac_iteration < 10,
                [best_fit, best_err, best_inlier] = ransac(light, sensor(:,sensor_idx), distance(1,sensor_idx), 10000, recover_threshold, 10, 0.2);
                
                if isempty(best_fit)
                    break;
                end
                
                if isnan(best_fit(1))
                    best_fit(6) = - best_fit(6);
                    pt = best_fit(4:6);
                    normal = nan(3,1);
                else
                    best_fit(3) = - best_fit(3);
                    best_inlier_idx = sensor_idx(1,best_inlier);
                    [pt, normal] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier_idx));
                end
                
                
                for i = length(best_inlier):-1:1,
                    sensor_idx(best_inlier(i)) = [];
                end
                
                recovered_pt  = [recovered_pt pt];
                recovered_normal = [recovered_normal repmat(normal,1,size(pt,2))];
                ransac_iteration = ransac_iteration + 1;
                
            end
            
            
            [space_carved_idx] = space_carving_check(X,Y,depth_map, recovered_pt, option);
            recovered_pt = recovered_pt(:,space_carved_idx);
            recovered_normal = recovered_normal(:,space_carved_idx);
            
            
            save(result_file, 'recovered_pt', 'recovered_normal');
        end
        
        
        sensor = vs';
        light =  vd(1,:)';
        
        figure; hold on;
        plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
        plot3(light(2), light(3), light(1), 'kx');
        
        
        
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
        
        
        
        plot3(recovered_pt(2,:),recovered_pt(3,:),recovered_pt(1,:), 'r.');
        
        error_result(f) = mean(err);
        err_normal_result(f) = mean(err_normal);
        
        
        axis equal;
        hold off;
        view(-38,44);
        set(gca, 'fontsize', 28);
        
        
        
        
    end
end

