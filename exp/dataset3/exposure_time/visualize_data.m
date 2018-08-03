clc,clear,close all

fileprefix = '../../../data/dataset3-raw_data/ExposureDuration/';
addpath(genpath('../../../data/preprocess_code/Calibrate/'));

fileName = strcat(fileprefix,'data_10ms_-2_0.txt');

Uncal_data = dlmread(fileName);

for i = 1:size(Uncal_data,1),
    if mod(i,100)==1
        fprintf('i=%d\n',i);
    end
    data = aggregateAllTiming(Uncal_data(i,:));
    save(['pair2/' num2str(i)], 'data');
end
