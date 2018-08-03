clear; clc; close all;

addpath('../../reconstruction');
addpath('../../util');

acquisition_time = [20,40, 100, 200, 400, 1000, 2000, 4000, 10000];

T = 100;
%exp = 'MovingInZ';
%exp = 'MovingInX';
exp = 'RotatingInY';

bin_width = 4*10^-12;
speed_of_light = 299792458;
output_folder = [exp '-quadratic/'];
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end
first_photon_folder = ['../../data/dataset4-first_photon/' exp '/'];
transient_folder = strrep(first_photon_folder, 'first_photon', 'transient_data');

C = hsv(T);
for a = 1:length(acquisition_time)
    figure; hold on;

    for test = 1:T
        %test
        f = dir([first_photon_folder 'Acquisition_' num2str(test) '_TotalTacq' num2str(acquisition_time(a)) 'Matlab*']);
        filename = [first_photon_folder f(1,1).name];
        load(filename);
        
        %plot(first_photon);
        %continue;
        
        
        transient_filename = [transient_folder f(1,1).name];
        load(transient_filename);
        
        light = vd(1,:)';
        
        dist = first_photon*bin_width*speed_of_light;
        sensor = vs';
        sensor = sensor(:,~isnan(dist));
        dist_tmp = dist(~isnan(dist));
        
        
        result_file = [output_folder num2str(a, '%02d') '_' num2str(test, '%02d') '.mat'];
        
        if exist(result_file, 'file')
            load(result_file);
        else
            recover_threshold = 0.02;
            [best_fit, best_err, best_inlier] = ransac(light, sensor, dist_tmp', 10000, recover_threshold, 10, 0.22*sqrt(2));

            save(result_file, 'best_fit', 'best_err', 'best_inlier', 'light', 'sensor');
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
            [recovered_pt, normal(:,test)] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier));
        end
        title(test);
        plot3(recovered_pt(1,:), recovered_pt(2,:), recovered_pt(3,:), '.', 'color', C(test,:));
    end
end
