clear; clc; close all;

addpath('../../../util/');

calibrated_transient = 'SP_X_-625mm_24.4_90_Dt_3_1_2017_M1_168.mat';
load(calibrated_transient);
output_folder = '../../dataset3-gt/MaterialCharacterization/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

filename = [output_folder calibrated_transient];

speed_of_light = 299792458;
bin_width = 4*10^-12;

%% 
%x_pos = 770;
%theta_x = 16.8;
x_pos = -625;
theta_x = 24.4;

gt_n = [-1;0;0];
gt_n = roty(theta_x*sign(x_pos))*gt_n;
gt_p = [x_pos;0;0]/1000;



p = [0.56/2 0.56/2 -0.56/2 -0.56/2; 0.4 -0.16 -0.16 0.4; 0 0 0 0];
p = roty(-(90-theta_x)*sign(x_pos))*p;
p(1,:) = p(1,:) + x_pos/1000 - p(1,3); 
p(3,:) = p(3,:) - p(3,3);

%p = [0.56/2 0.56/2 -0.56/2 -0.56/2; 0.37 -0.19 -0.19 0.37; 0 0 0 0];
%p = roty(-(90-theta_x)*sign(x_pos))*p;
%p(1,:) = p(1,:) + x_pos/1000 - p(1,1); 
%p(3,:) = p(3,:) - p(3,1);



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
        if gt_point(1,i) < p(1,3) || gt_point(1,i) > p(1,1) || gt_point(2,i) < p(2,3) || gt_point(2,i) > p(2,1)
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

