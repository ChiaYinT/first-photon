clear; clc; close all;

addpath('../../../util/');

calibrated_transient = '03_22_2017_60deg_1ms.mat';
load(calibrated_transient);
filename = ['../../dataset3-gt/IntegrationTimePlane/03_22_2017_60deg.mat'];

speed_of_light = 299792458;
bin_width = 4*10^-12;

%% 
x_pos = 1090;
theta_y = 90;
phi_y = 60;
gt_p = [x_pos;0;0]/1000;
gt_n = [-sind(theta_y)*sind(phi_y);-cosd(theta_y);sind(theta_y)*cosd(phi_y)];
p = [0 0 0 0;1 1 -1 -1; 0 -0.76*sind(phi_y) -0.76*sind(phi_y) 0];
for i =1:size(p,2),
   p(1,i) = (gt_p'*gt_n - p(2,i)*gt_n(2) - p(3,i)*gt_n(3))/gt_n(1);
end



figure;
plot3( vs(:,2), vs(:,3),vs(:,1), 'k.'); hold on;
plot3( vd(1,2), vd(1,3),vd(1,1), 'r.');
plot3(SourceLocation(2),-SourceLocation(3),SourceLocation(1),'kx');
plot3( DetectorLocation(2), -DetectorLocation(3),DetectorLocation(1), 'rx');
xlabel('y'); ylabel('z'); zlabel('x');
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
        if gt_point(1,i) < p(1,2) || gt_point(1,i) > p(1,1) || gt_point(2,i) < p(2,3) || gt_point(2,i) > p(2,1)
            [gt_point(:,i), d_plane] = find_shortest_path_through_polygon([0;0;0], vs(i,:)', p);
            gt_first_photon(i) = ceil(d_plane/speed_of_light/bin_width);
        end
%         if gt_point(2,i) < p(2,2) || gt_point(2,i) > p(2,1)
%                [gt_point(:,i), d_plane] = find_shortest_path_through_polygon([0;0;0], vs(i,:)', p);
%                gt_first_photon(i) = ceil(d_plane/speed_of_light/bin_width);
%         end

    end
end

plot3(gt_point(2,:), gt_point(3,:), gt_point(1,:), 'g.');

save(filename, 'p', 'gt_first_photon', 'gt_point', 'gt_p', 'gt_n');

