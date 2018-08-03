clear; clc; close all;

addpath('../../../util/');


calibrated_transient = ['03_22_2017_60deg_sphere1.mat'];
load(calibrated_transient);

figure;
plot3( vs(:,2), vs(:,3),vs(:,1), 'k.'); hold on;
plot3( vd(1,2), vd(1,3),vd(1,1), 'r.');
plot3(SourceLocation(2),-SourceLocation(3),SourceLocation(1),'kx');
plot3( DetectorLocation(2), -DetectorLocation(3),DetectorLocation(1), 'rx');
xlabel('y'); ylabel('z'); zlabel('x');


output_folder = '../../dataset3-gt/MultiObject/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

filename = [output_folder calibrated_transient];

speed_of_light = 299792458;
bin_width = 4*10^-12;


item = 1;

x_pos = 1090;
theta_y = 90;
phi_y = 60;
gt_p = [x_pos;0;0]/1000;
gt_n = [-sind(theta_y)*sind(phi_y);-cosd(theta_y);sind(theta_y)*cosd(phi_y)];
p = [0 0 0 0;1 1 -1 -1; 0 -0.76*sind(phi_y) -0.76*sind(phi_y) 0];
for i =1:size(p,2),
    p(1,i) = (gt_p'*gt_n - p(2,i)*gt_n(2) - p(3,i)*gt_n(3))/gt_n(1);
end
figure(1);
fill3(p(2,:), p(3,:), p(1,:), [0.8 0.8 0.8]);

virtual_light = find_mirror_position([0;0;0], gt_n, gt_p);

gt_first_photon = zeros(size(vs,1),1);
gt_point = zeros(3,size(vs,1));
for i = 1:size(vs,1),
    if virtual_light(3) > 0
        [gt_point(:,i), d_plane] = find_shortest_path_through_polygon([0;0;0], vs(i,:)', p);
        gt_first_photon(i) = ceil(d_plane/speed_of_light/bin_width);
    else
        
        [gt_point(:,i),check]=plane_line_intersect(gt_n,gt_p,vs(i,:)',virtual_light);
        gt_first_photon(i) = ceil(norm(virtual_light - vs(i,:)')/speed_of_light/bin_width);
        if gt_point(1,i) < min(p(1,:)) || gt_point(1,i) > max(p(1,:)) || gt_point(2,i) < min(p(2,:)) || gt_point(2,i) > max(p(2,:))
            [gt_point(:,i), d_plane] = find_shortest_path_through_polygon([0;0;0], vs(i,:)', p);
            gt_first_photon(i) = ceil(d_plane/speed_of_light/bin_width);
        end
    end
end

plot3(gt_point(2,:), gt_point(3,:), gt_point(1,:), 'g.');
p_collection{item,1} = p;
gt_first_photon_collection{item,1} = gt_first_photon;
gt_point_collection{item,1} = gt_point;
gt_p_collection{item,1} = gt_p;
gt_n_collection{item,1} = gt_n;


c = [-0.49; 0.27; -0.57];
r = [0.2706];

gt_first_photon = zeros(size(vs,1)*size(c,2),1);
gt_point = zeros(3,size(vs,1)*size(c,2));

for item = 1:size(c,2),
    gt_c = c(:,item);
    gt_r = r(:,item);
    
    [X,Y,Z] = sphere;
    X = gt_r*X + gt_c(1);
    Y = gt_r*Y + gt_c(2);
    Z = gt_r*Z + gt_c(3);
    
    
    h = surf(Y,Z,X);
    set(h, 'FaceColor', [0.8 0.8 0.8]);
    
    
    x0 = [0;0];
    for i = 1:size(vs,1),
        [gt_point(:,i + (item-1)*size(vs,1)), distance, normal_gt, x0] = min_dist_sphere(vd(1,:)', vs(i,:)', gt_r, gt_c, x0);
        gt_first_photon(i + (item-1)*size(vs,1)) = ceil(distance/speed_of_light/bin_width);
    end
end

plot3(gt_point(2,:), gt_point(3,:), gt_point(1,:), 'g.');
item = 2;
gt_first_photon_collection{item,1} = gt_first_photon;
gt_point_collection{item,1} = gt_point;

save(filename, 'p_collection', 'gt_first_photon_collection', 'gt_point_collection', 'gt_p_collection', 'gt_n_collection', 'c', 'r');

