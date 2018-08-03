clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/MaterialCharacterization/';
first_photon_folder =  '../../../data/dataset3-first_photon/MaterialCharacterization/';
transient_folder = '../../../data/dataset3-transient_data/MaterialCharacterization/';


test = 'SP_X_-625mm_24.4_90_Dt_3_1_2017_M1_168';
%test = 'SP_X_770mm_16.8_90_Dt_3_1_2017_M1_168';

figure; hold on;
c = hsv(3);
for i = 1:3
    file = [first_photon_folder strrep(test, 'M1', ['M' num2str(i)]) '.mat'];
    load(file);
    plot(first_photon, '-', 'color', c(i,:), 'LineWidth', 2);
end

gt_file = [first_photon_gt_folder test '.mat'];
load(gt_file);
plot(gt_first_photon, '-', 'color', [0 0 0], 'LineWidth', 2);

lgd = legend('M1', 'M2', 'M3', 'ground truth');
lgd.FontSize = 18;
xlabel('sensor ID');
ylabel('ToF');
xlim([1 168]);
set(gca, 'fontsize', 18);

figure; hold on;
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
    dist_tmp = dist(~isnan(dist));
    
    
    result_file = ['result-quadratic/' name '.mat'];
    
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
        sensor = vs';

        [recovered_pt, normal] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier));
    end
    
    
    rmse(i) = sqrt(nanmean((gt_n'*(recovered_pt-repmat(gt_p(:,1),1,size(recovered_pt,2)))).^2));
    normal_error(i) = acosd(abs(gt_n'*normal));
    
    plot3(recovered_pt(2,:),recovered_pt(3,:),recovered_pt(1,:), '.', 'color', c(i,:));
    
    
end

plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
plot3(light(2), light(3), light(1), 'kx');

fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);
axis equal;
hold off;
view(-38,44);
set(gca, 'fontsize', 25);
