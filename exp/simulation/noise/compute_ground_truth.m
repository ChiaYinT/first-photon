clear; clc; close all;

addpath('../../../reconstruction');
addpath('../../../util/');

date_folder = '1116';

load(['../../../simulation/setup/' date_folder]);

speed_of_light = 299792458;
show_geometry_setup = 1;
test_setup = 0;

exposure = pinhole_camera.exposure*10^-12;

% simulation
total_simulation_num = size(cam_X,1)*size(cam_X,2);
tof_error = nan(1,total_simulation_num);
sensor = nan(3,total_simulation_num);
tof_gt = nan(1,total_simulation_num);
contributing_pt = nan(3,total_simulation_num);
normal_gt = nan(3,total_simulation_num);

x0 = [pi/2 0];
for simulation_it = 1:size(cam_X,1)*size(cam_X,2),
    sensor(:,simulation_it) = [cam_X(simulation_it) cam_Y(simulation_it) 0]';
    % camera
    pinhole_camera.position = [cam_X(simulation_it) cam_Y(simulation_it) 0]';    
    pinhole_camera.focus = [cam_X(simulation_it) cam_Y(simulation_it) 1]';
    pinhole_camera.direction = pinhole_camera.focus - pinhole_camera.position;
    pinhole_camera.nv = pinhole_camera.direction/norm(pinhole_camera.direction);
    pinhole_camera.uv = cross(pinhole_camera.nv,pinhole_camera.up);
    pinhole_camera.uv = pinhole_camera.uv/norm(pinhole_camera.uv);
    pinhole_camera.vv = cross(pinhole_camera.uv, pinhole_camera.nv);
    pinhole_camera.vv = pinhole_camera.vv/norm(pinhole_camera.vv);
    
    [distance_gt, contributing_pt(:,simulation_it), normal_gt(:,simulation_it), x0] = find_shortest_path_sphere(light, pinhole_camera.position, sphere_c, sphere_r, x0);
    tof_gt(1,simulation_it) = distance_gt/speed_of_light;
    
    [d,pt(:,simulation_it)] = find_longest_path_sphere(light, pinhole_camera.position, sphere_c, sphere_r, x0);
    tof_largest_gt(1,simulation_it) = d/speed_of_light;
end

save('ground_truth_1116', 'tof_gt', 'sensor');