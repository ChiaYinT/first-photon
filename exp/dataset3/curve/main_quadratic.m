clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/CurvedObject/';
first_photon_folder = strrep(first_photon_gt_folder, 'gt', 'first_photon');
transient_folder = strrep(first_photon_gt_folder, 'gt', 'transient_data');

output_folder = 'result-quadratic/';
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
            
            
            save(result_file, 'recovered_pt', 'recovered_normal');
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
        
        
        plot3(recovered_pt(2,:),recovered_pt(3,:),recovered_pt(1,:), 'r.');
        
        axis equal;
        hold off;
        view(-38,44);
        set(gca, 'fontsize', 28);
        
        
        
        err = ones(1,size(recovered_pt,2))*realmax;
        norm_err = nan(1,size(recovered_pt,2));

        for item = 1:size(c,2)
            
            gt_c = c(:,item);
            gt_r = r(:,item);
            
            [sphere_X,sphere_Y,sphere_Z] = sphere;
            sphere_X = gt_r*sphere_X + gt_c(1);
            sphere_Y = gt_r*sphere_Y + gt_c(2);
            sphere_Z = gt_r*sphere_Z + gt_c(3);
            
            
            for j = 1:size(recovered_pt,2)
                v = recovered_pt(:,j) - gt_c;
                d = norm(v);
                tmp_err = abs(d - gt_r);
                if tmp_err < err(j)
                    err(j) = tmp_err;
                    v = v/d;
                    
                    norm_err(j) = acosd(abs(recovered_normal(:,j)'*v));
                end
            end
        end
        rmse(f) = sum(err)/length(err);
        rmse_normal(f) = sum(norm_err)/length(err);

        %rmse(f) = sqrt(err*err'/length(err));
        fprintf('local planar rmse = %f\n', rmse(f));
        
    end
end

filename = [output_folder 'quantitative'];
save(filename, 'rmse', 'rmse_normal');
