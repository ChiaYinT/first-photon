clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/IntegrationTimePlane/';
first_photon_folder =  strrep(first_photon_gt_folder, 'gt', 'first_photon');
transient_folder = strrep(first_photon_gt_folder, 'gt', 'transient_data');

output_folder = 'result-quadratic/';

if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
time = [1, 100, 5000];
%time = [1, 100, 500, 1000, 5000];
test = '03_22_2017_60deg';
load([first_photon_gt_folder test]);


figure; hold on;
c = hsv(length(time));

f = 1;
name = [test '_' num2str(time(f)) 'ms.mat'];
load([first_photon_folder name]);
plot(first_photon, '-', 'color', c(f,:), 'LineWidth', 2);
f = 2;
name = [test '_' num2str(time(f)) 'ms.mat'];
load([first_photon_folder name]);
plot(first_photon, '--', 'color', c(f,:), 'LineWidth', 3);
f = 3;
name = [test '_' num2str(time(f)) 'ms.mat'];
load([first_photon_folder name]);
plot(first_photon, ':', 'color', c(f,:), 'LineWidth', 2);

plot(gt_first_photon,'k-.', 'LineWidth', 2)

lgd = legend('1ms', '100ms', '5000ms', 'ground truth');
set(lgd, 'FontSize', 18);
xlabel('sensor ID');
ylabel('ToF');
xlim([0 168]);
set(gca, 'fontsize', 28);

% for f = 1:length(time)
%     name = [test '_' num2str(time(f)) 'ms.mat'];
%     
%     load([first_photon_folder name]);
%     plot(first_photon, '-', 'color', c(f,:), 'LineWidth', 2);
%     %    plot(first_photon+ (f-3)*100, '-', 'color', c(f,:), 'LineWidth', 2);
% end


figure;
hold on;

for f = 1:length(time)
    name = [test '_' num2str(time(f)) 'ms.mat'];
    
    load([first_photon_folder name ]);
    
    transient_file = [transient_folder name ];
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
    
    
    rmse(f) = sqrt(nanmean((gt_n'*(recovered_pt-repmat(gt_p(:,1),1,size(recovered_pt,2)))).^2));
    normalerror(f) = acosd(abs(gt_n'*normal));
    
    plot3(recovered_pt(2,:),recovered_pt(3,:),recovered_pt(1,:), '.', 'color', c(f,:));
    
    
end

plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
plot3(light(2), light(3), light(1), 'kx');

fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);
zlim([-0.5 1.3]);
ylim([-0.7 0]);

hold off;
view(-38,44);
set(gca, 'fontsize', 25);
