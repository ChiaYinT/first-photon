clear; clc; close all;

%exp_name = 'CurvedObject';
exp_name = 'MultiPlane';

folder = ['../../dataset3-transient_data/' exp_name '/'];
gt_folder = ['../../dataset3-gt/' exp_name '/'];

output_folder = strrep(folder,'transient_data', 'first_photon');
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

f = dir(folder);

for i =  3:size(f,1)
    file_name = f(i,1).name;
    if length(file_name) < 2,
        continue;
    end
    
    if strcmp(file_name(1:2), '03') == 1

        filename = [folder file_name];
        filename
        load(filename);
        filename = [gt_folder file_name];
        if exist(filename, 'file')
            load([gt_folder file_name]);
        end 
        opt.show_transient = 1;
        %opt.item_num = 1;
        opt.edge_threshold = 18;
        %opt.edge_threshold = input('edge threshold = ');
       
            
        %opt.mask_bin = mask_bin(i);
        
        [first_photon] = find_first_photon(data, opt);
        output_file = [output_folder file_name];
        save(output_file, 'first_photon');
        
%         figure;
%         plot(gt_first_photon, 'r');
%         hold on
%         plot(first_photon, 'b');
%         hold off;
    end
end
