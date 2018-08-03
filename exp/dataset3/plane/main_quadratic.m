clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/PlaneCharacterization/';
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
        
        figure;
        plot(gt_first_photon,'r');
        hold on;
        plot(first_photon,'b');
        hold off;
        
        transient_file = [transient_folder name];
        load(transient_file);
        
        light = vd(1,:)';
        
        dist = first_photon*bin_width*speed_of_light;
        sensor = vs';
        sensor = sensor(:,~isnan(dist));
        dist_tmp = dist(~isnan(dist));
        
        result_file = [output_folder name];
        
        if exist(result_file, 'file')
            load(result_file);
        else
            recover_threshold = 0.03;
            [best_fit, best_err, best_inlier] = ransac(light, sensor, dist_tmp', 10000, recover_threshold, 10, 0.2);
            
            save(result_file, 'best_fit', 'best_err', 'best_inlier');
        end
        
        if isempty(best_fit)
            continue;
        end
        
        if isnan(best_fit(1))
            best_fit(6) = -best_fit(6);
            pt = best_fit(4:6,1);
            normal = nan(3,1);
        else
            best_fit(3) = -best_fit(3);
            [recovered_pt, normal] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier));
        end
        
        
        %rmse(f) = sqrt(nanmean((gt_n'*(recovered_pt-repmat(gt_p(:,1),1,size(recovered_pt,2)))).^2));
        rmse(f) = nanmean(abs(gt_n'*(recovered_pt-repmat(gt_p(:,1),1,size(recovered_pt,2)))));
        rmse_normal(f) = nanmean(acosd(abs(gt_n'*normal)));
        
        
        %normal_error(f) = acosd(gt_n'*normal);
        
        
        %figure;
        %plot(gt_first_photon, 'r'); hold on;
        %plot(first_photon, 'b');
        
        
        
        figure; hold on;
        plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
        plot3(light(2), light(3), light(1), 'kx');
        
        fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);
        plot3(recovered_pt(2,:),recovered_pt(3,:),recovered_pt(1,:), 'r.');
        plot3(gt_point(2,:),gt_point(3,:),gt_point(1,:), 'g.');

        axis equal;
        hold off;
        view(-38,44);
        set(gca, 'fontsize', 28);

    end
end

filename = [output_folder 'quantitative'];
save(filename, 'rmse', 'rmse_normal');
