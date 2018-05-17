clear; close all; clc;

[voxel_x, voxel_y, voxel_z] = meshgrid(-120:2:70, -20:2:70, 0:2:140);
load 'results/value_after_laplacian';


threshold = 0.20;

reconstruction = (abs(value_after_laplacian) > threshold);

point = voxel_z.*reconstruction;
point(point==0) = nan;
point(:,1,:) = nan;
point(1,:,:) = nan;
point(:,end,:) = nan;
point(end,:,:) = nan;
point(:,:,end) = nan;
figure; hold on;

plot3(voxel_x(:), voxel_y(:), point(:), '.', 'color', [0.8 0.8 0.8], 'MarkerSize', 10);



load 'results/reconstruction_first_photon_plane_cluster';

plane_color = hsv(size(plane_p,1));
for i = 1:size(plane_p,1),
    reconstructed_p = plane_p{i,1};
    reconstructed_n = plane_n{i,1};

    plot3(reconstructed_p(1,:), reconstructed_p(2,:), reconstructed_p(3,:), '.', 'color', plane_color(i,:), 'MarkerSize', 20);
    
end
view(151,42);

xlim([-100 50])
ylim([-20 70]);
zlim([0 130]);

xlabel('x'); ylabel('y'); zlabel('z');
%axis off;
axis equal;
set(gca, 'fontsize', 28);

figure; hold on;

plot3(voxel_x(:), voxel_y(:), point(:), '.', 'color', [0.8 0.8 0.8], 'MarkerSize', 10);
plane_color = hsv(size(plane_p,1));
length = 15;
for i = 1:size(plane_p,1),
    reconstructed_p = plane_p{i,1};
    reconstructed_n = plane_n{i,1};

    for j = 1:size(reconstructed_p,2)  
          quiver3(reconstructed_p(1,j), reconstructed_p(2,j), reconstructed_p(3,j),length*reconstructed_n(1,j),length* reconstructed_n(2,j), length*reconstructed_n(3,j), 'color', plane_color(i,:), 'MarkerSize', 12, 'MaxheadSize', 20, 'LineWidth', 2);
    end
end
view(151,42);

xlim([-100 50])
ylim([-20 70]);
zlim([0 130]);

xlabel('x'); ylabel('y'); zlabel('z');
%axis off;
axis equal;
set(gca, 'fontsize', 28);




figure; hold on;

plot3(voxel_x(:), voxel_y(:), point(:), '.', 'color', [0.8 0.8 0.8], 'MarkerSize', 10);
load 'results/reconstruction_first_photon';
plot3(reconstructed_p(1,:), reconstructed_p(2,:), reconstructed_p(3,:), '.', 'color', plane_color(1,:), 'MarkerSize', 20);
view(151,42);
xlim([-100 50])
ylim([-20 70]);
zlim([0 130]);

xlabel('x'); ylabel('y'); zlabel('z');

axis equal;
set(gca, 'fontsize', 28);




figure; hold on;

plot3(voxel_x(:), voxel_y(:), point(:), '.', 'color', [0.8 0.8 0.8], 'MarkerSize', 10);
%plot3(reconstructed_p(1,:), reconstructed_p(2,:), reconstructed_p(3,:), '.', 'color', plane_color(1,:), 'MarkerSize', 20);
for j = 1:size(reconstructed_p,2)  
    quiver3(reconstructed_p(1,j), reconstructed_p(2,j), reconstructed_p(3,j),length*reconstructed_n(1,j),length* reconstructed_n(2,j), length*reconstructed_n(3,j), 'color', 'r', 'MarkerSize', 12, 'MaxheadSize', 20, 'LineWidth', 2);
end
view(151,42);
xlim([-100 50])
ylim([-20 70]);
zlim([0 130]);

xlabel('x'); ylabel('y'); zlabel('z');

axis equal;
set(gca, 'fontsize', 28);

