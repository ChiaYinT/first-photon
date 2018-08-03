clear; clc; close all;

%exp_name = 'FixedPosition_x_closest';
%exp_name = 'MovingInX';
exp_name = 'RotatingInY';

folder = ['../../dataset4-transient_data/' exp_name '/'];

output_folder = strrep(folder,'transient_data', 'first_photon');
if ~exist(output_folder,'dir')
    mkdir(output_folder);
end

mask = [962.3448, 962.5862, 986.8276,994.5862 , 1002.9,...
        1018.8, 1042.8,  1042.8,  1066.8,  1074.8,...
        1082.8, 1058.8, 1050.8, 1082.8, 1082.8,...
        1058.8, 1034.8, 1066.8, 1050.2, 1074.8];

f = dir(folder);

for i =  3:size(f,1)
    file_name = f(i,1).name;
    if length(file_name) < 2,
        continue;
    end
    
    if strcmp(file_name(1:2), 'To') == 1 || strcmp(file_name(1:2), 'Ac') == 1

        filename = [folder file_name];
        filename
        load(filename);
        
        opt.show_transient = 1;
        opt.item_num = 1;
        opt.edge_threshold = 200;
                   
        first_photon = zeros(size(data,1),1);
        for j = 1:size(data,1)
            opt.mask_bin = mask(j);
            [first_photon(j)] = find_first_photon(double(data(j,:)), opt);
        end
        output_file = [output_folder file_name];
        save(output_file, 'first_photon');
        
    end
end
