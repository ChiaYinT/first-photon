function [pt] = locate_point_on_wall(pixel)
load('../../dataset3-raw_data/calibration/camera_calibration/03_26_2017/Calib_Results');
%I = double(imread('..\raw_data\calibration\03-01-2017_virtual_detector.png'));
%centroid=detectCentroid(I);
load('wall_transformation');
xn = normalize(pixel,fc,cc,kc,alpha_c);
a = normal'*t/(normal'*[xn;1]);
pt = a*[xn;1];
