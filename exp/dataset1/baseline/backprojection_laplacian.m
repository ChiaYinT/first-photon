clear; clc; close all;

load '../../../data/dataset.mat';



tof_distance = dataset.t0 + (1:dataset.t)*dataset.deltat;
[voxel_x, voxel_y, voxel_z] = meshgrid(-120:2:70, -20:2:70, 0:2:140);

d3 = sqrt((voxel_x-dataset.cameraPos(1)).^2 + (voxel_y-dataset.cameraPos(2)).^2 + (voxel_z-dataset.cameraPos(3)).^2);

v4 = dataset.cameraOrigin - dataset.cameraPos;
r4 = norm(v4);
v4 = v4/r4;

cos_val = (voxel_z-dataset.cameraPos(3))./d3;

val_output = '../results/value.mat';
if exist(val_output, 'file')
    load(val_output);
else
    value = zeros(size(voxel_x));
    
    for i = 1:size(dataset.data,1),
        fprintf('i = %d\n', i);
        r1 = norm(dataset.laserOrigin -  dataset.laserPos(i,:));
        d2 = sqrt((voxel_x-dataset.laserPos(i,1)).^2 + (voxel_y-dataset.laserPos(i,2)).^2 + (voxel_z-dataset.laserPos(i,3)).^2);
        
        d = r1 + d2 + d3 + r4;
        
        for t = 1:size(dataset.data,3),
            N = dataset.data(i,1,t);
            occupancy = abs(d-tof_distance(1,t)) < sqrt(3);
            value = value + occupancy.*N.*r1.*d3.*cos_val;
        end
    end
    
    save(val_output, 'value');
end

val_laplace_output = '../results/value_after_laplacian.mat';
if exist(val_laplace_output, 'file')
    load(val_laplace_output);
else
    
    
    value_after_laplacian = zeros(size(value));
    [~,~,A] = laplacian(size(value));
    for i = 1:size(A,2),
        L = reshape(full(A(:,i)), size(value));
        tmp_val = value.*L;
        value_after_laplacian(i) = sum(tmp_val(:));
    end
    
    value_after_laplacian = value_after_laplacian/max(value_after_laplacian(:));
    
    save(val_laplace_output, 'value_after_laplacian');
end