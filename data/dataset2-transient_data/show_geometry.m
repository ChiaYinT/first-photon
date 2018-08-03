clear; clc; close all;

addpath('../../util/');

folder = dir();

speed_of_light = 299792458;
bin_width = 4*10^-12;

output_folder = '../dataset2-gt/';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


for f = 1:size(folder,1),
    calibrated_transient = folder(f,1).name;
    if length(calibrated_transient) < 3,
        continue;
    end
    if strcmp(calibrated_transient(1:2),'SP')==0
        continue;
    end
    %name = 'SP_Y_600_21.1_0_Dt_12_4_2016_48.mat';
    calibrated_transient
    load(calibrated_transient);
    filename = ['../dataset2-gt/' calibrated_transient];
    
    [tmp1, tmp2, y_pos, theta_y, phi_y,tmp3,tmp4,tmp5,tmp6,tmp7,tmp8] =strread(calibrated_transient,'%s%s%d%f%d%s%d%d%d%d%s','delimiter','_');
    
    
    gt_p = [0;y_pos;0]/1000;
    gt_n = [-sind(theta_y)*sind(phi_y);-cosd(theta_y);sind(theta_y)*cosd(phi_y)];
    
    
    figure;
    plot3( vs(:,2), vs(:,3),vs(:,1), 'k.'); hold on;
    plot3( vd(1,2), vd(1,3),vd(1,1), 'r.');
    plot3(SourceLocation(2),-SourceLocation(3),SourceLocation(1),'kx');
    plot3( DetectorLocation(2), -DetectorLocation(3),DetectorLocation(1), 'rx');
    xlabel('y'); ylabel('z'); zlabel('x');
    
    p = [0.5 0.5 -0.5 -0.5; 0 0 0 0; 0 -1 -1 0];
    for i =1:size(p,2),
        p(2,i) = (gt_p'*gt_n - p(1,i)*gt_n(1) - p(3,i)*gt_n(3))/gt_n(2);
    end
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
            if gt_point(1,i) > p(1,2) || gt_point(1,i) < p(1,3) || gt_point(2,i) < p(2,3) || gt_point(2,i) > p(2,1)
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
     
end




