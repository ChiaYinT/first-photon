close all; clear all; clc;
load 'dataset.mat';

s = dataset.laserPos';
light = dataset.cameraPos';

figure; hold on;
axis equal; 
h = fill3([-100 50 50 -100], [-20 -20 100 100], [0 0 0 0], [0.8 0.8 0.8]);
set(h,'EdgeColor', 'none');
plot3(dataset.cameraPos(:,1), dataset.cameraPos(:,2), dataset.cameraPos(:,3), 'b.'); %camera positions
plot3(dataset.laserPos(:,1), dataset.laserPos(:,2), dataset.laserPos(:,3), 'r.') %laser positions
plot3(dataset.cameraOrigin(:,1), dataset.cameraOrigin(:,2), dataset.cameraOrigin(:,3), 'b.') % camera origin
plot3(dataset.laserOrigin(:,1), dataset.laserOrigin(:,2), dataset.laserOrigin(:,3), 'r.') % camera origin
set(gca, 'FontSize', 18);
text(dataset.cameraOrigin(1),dataset.cameraOrigin(2),dataset.cameraOrigin(3),'   SPAD','HorizontalAlignment','left','FontSize',18, 'Color', 'w');
text(dataset.laserOrigin(1),dataset.laserOrigin(2),dataset.laserOrigin(3),'   laser','HorizontalAlignment','left','FontSize',18, 'Color', 'w');
text(30, 80 ,20,'   field of view','HorizontalAlignment','right','FontSize',18, 'Color', 'w');



fov_color = [51 153 255]/255;
f = fill3([dataset.laserOrigin(1) -80 30], [dataset.laserOrigin(2) -5 -5 ], [dataset.laserOrigin(3) 0 0], fov_color);
set(f, 'EdgeColor', fov_color);
alpha(f,0.2);
f = fill3([dataset.laserOrigin(1) -80 -80], [dataset.laserOrigin(2) -5 80 ], [dataset.laserOrigin(3) 0 0], fov_color);
set(f, 'EdgeColor', fov_color);
alpha(f,0.2);
f = fill3([dataset.laserOrigin(1) -80 30], [dataset.laserOrigin(2) 80 80 ], [dataset.laserOrigin(3) 0 0], fov_color);
set(f, 'EdgeColor', fov_color);
alpha(f,0.2);
f = fill3([dataset.laserOrigin(1) 30 30], [dataset.laserOrigin(2) 80 -5 ], [dataset.laserOrigin(3) 0 0], fov_color);
set(f, 'EdgeColor', fov_color);
alpha(f,0.2);





T_shape = [0 38 38 23 23 15 15 0; 41 41 32 32 0 0 32 32];
T_shape = [T_shape; zeros(1,size(T_shape,2))];
R = roty(42);
T_shape = R*T_shape;
T_shape = T_shape + repmat([5;0;83],1,size(T_shape,2));
f = fill3(T_shape(1,:), T_shape(2,:), T_shape(3,:), [0.8 0.8 0.8]*0.8);
set(f, 'EdgeColor', 'none');
text(T_shape(1,2),T_shape(2,2),T_shape(3,2),'   T shape','HorizontalAlignment','left','FontSize',18, 'Color', 'w');



square_L = [0 20 20 0; 0 0 20 20];
square_L = [square_L; zeros(1,size(square_L,2))];
R = roty(22);
square_L = R*square_L;
R = rotx(10);
square_L = R*square_L;
square_L = square_L + repmat([10;-10;110],1,size(square_L,2));
f = fill3(square_L(1,:), square_L(2,:), square_L(3,:), [0.8 0.8 0.8]*0.8);
set(f, 'EdgeColor', 'none');
text(square_L(1,2),square_L(2,2),square_L(3,2),'   large square','HorizontalAlignment','right','FontSize',18, 'Color', 'w');



square_s = [0 10 10 0; 0 0 10 10];
square_s = [square_s; zeros(1,size(square_s,2))];
R = roty(-38);
square_s = R*square_s;
R = rotx(0);
square_s = R*square_s;
square_s = square_s + repmat([-80;35;55],1,size(square_s,2));
f = fill3(square_s(1,:), square_s(2,:), square_s(3,:), [0.8 0.8 0.8]*0.8);
set(f, 'EdgeColor', 'none');
text(square_s(1,1),square_s(2,1),square_s(3,1),'   small square','HorizontalAlignment','left','FontSize',18, 'Color', 'w');


figure; imagesc(squeeze(dataset.data));
set(gca, 'FontSize', 18);


