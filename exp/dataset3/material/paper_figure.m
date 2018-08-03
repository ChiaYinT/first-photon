clear; clc; close all;

addpath('../../../util');
addpath('../../../reconstruction');


bin_width = 4*10^-12;
speed_of_light = 299792458;

first_photon_gt_folder =  '../../../data/dataset3-gt/MaterialCharacterization/';
first_photon_folder =  '../../../data/dataset3-first_photon/MaterialCharacterization/';
transient_folder = '../../../data/dataset3-transient_data/MaterialCharacterization/';


%test = 'SP_X_-625mm_24.4_90_Dt_3_1_2017_M1_168';
test = 'SP_X_770mm_16.8_90_Dt_3_1_2017_M1_168';


sz = 50;    % length of gaussFilter vector
sigma = ceil(sz/2);
x = linspace(-sz / 2, sz / 2, sz);
gaussFilter = exp(-x .^ 2 / (2 * sigma ^ 2));
gaussFilter = gaussFilter / sum (gaussFilter);

id = 78;

figure(1); hold on;
figure(2); hold on;

c = hsv(3);
for i = 1:3
    name = strrep(test, 'M1', ['M' num2str(i)]);
    file = [first_photon_folder name '.mat'];
    load(file);
    figure(2);
    plot(first_photon, 'color', c(i,:));
    file = [transient_folder name '.mat'];
    load(file);
    
    mask_bin = 956;
    data(id,1:mask_bin) = 0;

    data_smoothed = conv(data(id,:), gaussFilter, 'same');

    
    
    figure(1);
    subplot(3,1,i);
    %plot(data_smoothed, 'b-', 'LineWidth', 2);
    plot(data(id,:), 'b-',  'LineWidth', 2);
    hold on;
    %plot(first_photon(id), data_smoothed(first_photon(id)), 'ro');
    plot(first_photon(id), data(id,first_photon(id)), 'ro', 'MarkerSize', 8);
    ylim([0 5000]);
end


