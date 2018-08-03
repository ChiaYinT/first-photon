clear; clc; close all;


bin_width = 4*10^-12;
speed_of_light = 299792458;
%exp_name = 'FixedPosition_z_';

exp_name = 'FixedPosition_x_';
acquisition_time = [20, 40, 100, 200, 400, 1000, 2000, 4000, 10000];
z_pos = {'closest'; 'midway'; 'farthest';};


C = hsv(length(acquisition_time));
for e = 1:size(z_pos,1)
    exp = [exp_name z_pos{e,1}];
    first_photon_folder = ['../../data/dataset4-first_photon/' exp '/'];
    transient_folder = strrep(first_photon_folder, 'first_photon', 'transient_data');
    output_folder = [exp '-quadratic/'];
    
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
    figure(e); hold on;

    for a = 1:length(acquisition_time)
        f = dir([first_photon_folder 'TotalTacq' num2str(acquisition_time(a)) 'Matlab*']);
        filename = [first_photon_folder f(1,1).name];
        load(filename);
        
        transient_filename = [transient_folder f(1,1).name];
        load(transient_filename);
       
        light = vd(1,:)';
        
        dist = first_photon*bin_width*speed_of_light;
        sensor = vs';
        sensor = sensor(:,~isnan(dist));
        dist_tmp = dist(~isnan(dist));
        
        
        
        result_file = [output_folder num2str(a, '%02d')  '.mat'];
        
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
            [recovered_pt, normal] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier));
        end
        figure(e);
        plot3(recovered_pt(1,:),recovered_pt(2,:),recovered_pt(3,:), '.', 'color', C(a,:));
        
    end
end

figure; hold on;
C = hsv(length(z_pos));

for e = 1:size(z_pos,1)
    exp = [exp_name z_pos{e,1}];
    first_photon_folder = ['../../data/dataset4-first_photon/' exp '/'];
    
    for a = 1:length(acquisition_time)
        f = dir([first_photon_folder 'TotalTacq' num2str(acquisition_time(a)) 'Matlab*']);
        filename = [first_photon_folder f(1,1).name];
        load(filename);
        plot(a,first_photon(20), '.', 'Color', C(e,:));
    end
end

figure; hold on;

for e = 1:size(z_pos,1)
    exp = [exp_name z_pos{e,1}];
    first_photon_folder = ['../../data/dataset4-first_photon/' exp '/'];
    transient_folder = strrep(first_photon_folder, 'first_photon', 'transient_data');
    output_folder = [exp '-quadratic/'];
    
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end
    
   
    for a = 1:length(acquisition_time)
        f = dir([first_photon_folder 'TotalTacq' num2str(acquisition_time(a)) 'Matlab*']);
        filename = [first_photon_folder f(1,1).name];
        load(filename);
        
        transient_filename = [transient_folder f(1,1).name];
        load(transient_filename);
       
        light = vd(1,:)';
        
        dist = first_photon*bin_width*speed_of_light;
        sensor = vs';
        sensor = sensor(:,~isnan(dist));
        dist_tmp = dist(~isnan(dist));
        
        
        
        result_file = [output_folder num2str(a, '%02d')  '.mat'];
        
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
            [recovered_pt, normal] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier));
        end
        plot3(recovered_pt(1,:),recovered_pt(2,:),recovered_pt(3,:), '.', 'color', C(e,:));
        
    end
    
    if strcmp(exp_name, 'FixedPosition_x_') == 1
        p = [.42 .92 .92 .42; -.36 -.36 .54 .54; -.95 -.45 -.45 -.95];
    else
        
        p = [.82 .82, .3 .3; -.1 .76 .76 -.1; -.33 -.33 -.8 -.8];
    end
    fill3(p(1,:), p(2,:), p(3,:), [0.8 .8 .8]);
    
end
