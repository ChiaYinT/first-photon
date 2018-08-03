clear; clc; close all;

addpath('../../../util/');

calibrated_file = '03_23_2017_smallsphere1.mat';
load(calibrated_file);
filename = ['../../dataset3-gt/CurvedObject/' calibrated_file];

speed_of_light = 299792458;
bin_width = 4*10^-12;
 
c = [0.49;-0.4;-0.741];
r = 0.076;


figure;
plot3( vs(:,2), vs(:,3),vs(:,1), 'k.'); hold on;
plot3( vd(1,2), vd(1,3),vd(1,1), 'r.');
plot3(SourceLocation(2),-SourceLocation(3),SourceLocation(1),'kx');
plot3( DetectorLocation(2), -DetectorLocation(3),DetectorLocation(1), 'rx');



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
xlabel('y'); ylabel('z'); zlabel('x');
axis equal;

save(filename, 'gt_first_photon', 'gt_point', 'c', 'r');