clear; clc; close all;

addpath('../../../util/');
addpath('../../../data/preprocess_code/Calibrate/');

addpath('C:\matlab_toolbox\toolbox_calib\TOOLBOX_calib');
load('../../dataset3-raw_data/calibration/camera_calibration/03_26_2017/Calib_Results.mat');

item_num = 3;
scene = 5;

calibrated_transient = ['03_24_2017_scene' num2str(scene) '.mat'];
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


camera_center = -Rc_29'*Tc_29;
file = '../../dataset3-raw_data/calibration/03-01-2017_virtual_detector.png';
I = imread(file);

centroid= DetectCentroid(I,[])'-[1;1];
[xn] = normalize(centroid,fc,cc,kc,alpha_c);
v = Rc_29'*[xn;1];

alpha = -camera_center(3)/v(3);
virtual_detector_position = camera_center+alpha*v;


for item = 1:item_num-1
    calib_output = ['calib/' num2str(scene) '-' num2str(item) '.mat'];
    if exist(calib_output,'file')
        load(calib_output);
    else
        I = im2double(imread(['scene_setup/scene' num2str(scene) '.png']));
        wintx = 5;
        winty = 5;
        [x_kk,X_KK,n_sq_x,n_sq_y,ind_orig,ind_x,ind_y] = extract_grid(I,wintx,winty,fc,cc,kc,dX,dY);
        [omckk,Tckk,Rckk,H,x,ex,JJ] = compute_extrinsic(x_kk,X_KK,fc,cc,kc,alpha_c);
        
        save(calib_output, 'omckk','Tckk','Rckk','x_kk', 'X_KK');
    end
    
    camera_ckk= -Rckk'*Tckk;
    I = im2double(imread(['scene_setup/scene' num2str(scene) '.png']));
    figure;imagesc(I);
    [x,y] = ginput(4);
    [xn] = normalize([(x-1)';(y-1)'],fc,cc,kc,alpha_c);
    v = Rckk'*[xn;ones(1,4)];
    
    alpha = -camera_ckk(3)./v(3,:);
    
    plane_position = repmat(camera_ckk,1,4) +repmat(alpha,3,1).*v ;
    plane_position_wall = Rc_29'*(Rckk*plane_position + repmat(Tckk - Tc_29,1,4)) - repmat(virtual_detector_position,1,4);
    plane_position_wall = [plane_position_wall(2,:); plane_position_wall(1,:); -plane_position_wall(3,:)];
    
    
    plane_normal = Rc_29'*Rckk*[0;0;1];
    plane_normal_wall = [plane_normal(2);plane_normal(1);-plane_normal(3)];
    
    gt_n = plane_normal_wall;
   
    p = plane_position_wall/1000;
    
    if (item == 2)
        v1 = p(:,1) - p(:,2);
        v1 = v1/norm(v1);
        p(:,1) = p(:,2) + v1;
        v2 = p(:,3) - p(:,2);
        v2 = v2/norm(v2);
        p(:,3) = p(:,2) + v2;
        p(:,4) = p(:,2) + v1 + v2;
    end
 
        
        
    
    
    gt_p = p(:,1);
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
    figure(1);
    plot3(gt_point(2,:), gt_point(3,:), gt_point(1,:), 'g.');
    
    p_collection{item,1} = p;
    gt_first_photon_collection{item,1} = gt_first_photon;
    gt_point_collection{item,1} = gt_point;
    gt_p_collection{item,1} = gt_p;
    gt_n_collection{item,1} = gt_n;
    
end


item = item+1;

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




save(filename, 'p_collection', 'gt_first_photon_collection', 'gt_point_collection', 'gt_p_collection', 'gt_n_collection');

