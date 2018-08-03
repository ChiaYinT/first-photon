clear; clc; close all;

folder = ['../../dataset2-transient_data/' ];
output_folder = strrep(folder,'transient_data', 'first_photon');
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

f = dir(folder);

mask_bin_list = [nan nan 439 445 475 460 475 460 688 681 482 nan];


for i =  1:size(f,1)
    file_name = f(i,1).name;
    if length(file_name) < 2,
        continue;
    end
    
    if strcmp(file_name(1:2), 'SP') == 1

        filename = [folder file_name];
        filename
        load(filename);
        opt.show_transient = 1;
        opt.item_num = 1;
        opt.edge_threshold = 50000;
        opt.mask_bin = mask_bin_list(i);

        [first_photon] = find_first_photon(data, opt);
        output_file = [output_folder file_name];
        save(output_file, 'first_photon');
    end
    pause(0.5);
end
