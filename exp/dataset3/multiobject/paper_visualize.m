clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_folder =  '../../../data/dataset3-first_photon/MultiObject/';
transient_folder = strrep(first_photon_folder, 'first_photon', 'transient_data');
first_photon_gt_folder = strrep(first_photon_folder, 'first_photon', 'gt');

output_folder = 'result-quadratic/';
output_folder2 = 'result/';

file = dir(first_photon_folder);
for f = size(file,1)
    if length(file(f,1).name)>2
        name = file(f,1).name;
        name
        gt_file = [first_photon_gt_folder name];
        load(gt_file);
        
        first_photon_file = [first_photon_folder name];
        load(first_photon_file);
        
        
        transient_file = [transient_folder name];
        load(transient_file);
        
        
        sensor = vs';
        light =  vd(1,:)';
        
        figure; hold on;
        %plot3(sensor(2,:), sensor(3,:), sensor(1,:), 'b.');
        %plot3(light(2), light(3), light(1), 'kx');
        
        for item = 1:size(p_collection,1)
            
            p = p_collection{item,1};
            gt_p = gt_p_collection{item,1};
            n = gt_n_collection{item,1};
            gt_point = gt_point_collection{item,1};
            fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);
            
        end
        

        result_file = [output_folder name];
        load(result_file);
        plot3(recovered_pt(2,:),recovered_pt(3,:),recovered_pt(1,:), 'r.');

        result_file = [output_folder2 name];
        load(result_file);
        for i = 1:size(plane_p,1)
            recovered_pt = plane_p{i,1};
            plot3(recovered_pt(2,:),recovered_pt(3,:),recovered_pt(1,:), 'b.');
        end 
        
        
        axis equal;
        hold off;
        view(-38,44);
        set(gca, 'fontsize', 28);
        
    end
end

