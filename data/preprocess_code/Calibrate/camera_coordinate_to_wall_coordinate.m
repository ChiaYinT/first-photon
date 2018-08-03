clear; clc; close all;

addpath('C:\\matlab_toolbox\toolbox_calib\TOOLBOX_calib\');
load('../../dataset3-raw_data/calibration/camera_calibration/03_26_2017/Calib_Results');

I = double(imread('../../dataset3-raw_data/calibration/camera_calibration/03_26_2017/29.tif'));

if size(I,3)>1,
   I = I(:,:,2);
end;


fprintf(1,'\nExtraction of the grid corners on the image\n');

disp('Window size for corner finder (wintx and winty):');
wintx = input('wintx ([] = 5) = ');
if isempty(wintx), wintx = 5; end;
wintx = round(wintx);
winty = input('winty ([] = 5) = ');
if isempty(winty), winty = 5; end;
winty = round(winty);

fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);


[x_ext,X_ext,n_sq_x,n_sq_y,ind_orig,ind_x,ind_y] = extract_grid(I,wintx,winty,fc,cc,kc);



%%% Computation of the Extrinsic Parameters attached to the grid:

[omc_ext,Tc_ext,Rc_ext,H_ext] = compute_extrinsic(x_ext,X_ext,fc,cc,kc,alpha_c);


%%% Reproject the points on the image:

[x_reproj] = project_points2(X_ext,omc_ext,Tc_ext,fc,cc,kc,alpha_c);

err_reproj = x_ext - x_reproj;

err_std2 = std(err_reproj')';


Basis = [X_ext(:,[ind_orig ind_x ind_orig ind_y ind_orig ])];

VX = Basis(:,2) - Basis(:,1);
VY = Basis(:,4) - Basis(:,1);

nX = norm(VX);
nY = norm(VY);

VZ = min(nX,nY) * cross(VX/nX,VY/nY);

Basis = [Basis VZ];

[x_basis] = project_points2(Basis,omc_ext,Tc_ext,fc,cc,kc,alpha_c);

dxpos = (x_basis(:,2) + x_basis(:,1))/2;
dypos = (x_basis(:,4) + x_basis(:,3))/2;
dzpos = (x_basis(:,6) + x_basis(:,5))/2;



figure(2);
image(I);
colormap(gray(256));
hold on;
plot(x_ext(1,:)+1,x_ext(2,:)+1,'r+');
plot(x_reproj(1,:)+1,x_reproj(2,:)+1,'yo');
h = text(x_ext(1,ind_orig)-25,x_ext(2,ind_orig)-25,'O');
set(h,'Color','g','FontSize',14);
h2 = text(dxpos(1)+1,dxpos(2)-30,'X');
set(h2,'Color','g','FontSize',14);
h3 = text(dypos(1)-30,dypos(2)+1,'Y');
set(h3,'Color','g','FontSize',14);
h4 = text(dzpos(1)-10,dzpos(2)-20,'Z');
set(h4,'Color','g','FontSize',14);
plot(x_basis(1,:)+1,x_basis(2,:)+1,'g-','linewidth',2);
title('Image points (+) and reprojected grid points (o)');
hold off;


fprintf(1,'\n\nExtrinsic parameters:\n\n');
fprintf(1,'Translation vector: Tc_ext = [ %3.6f \t %3.6f \t %3.6f ]\n',Tc_ext);
fprintf(1,'Rotation vector:   omc_ext = [ %3.6f \t %3.6f \t %3.6f ]\n',omc_ext);
fprintf(1,'Rotation matrix:    Rc_ext = [ %3.6f \t %3.6f \t %3.6f\n',Rc_ext(1,:)');
fprintf(1,'                               %3.6f \t %3.6f \t %3.6f\n',Rc_ext(2,:)');
fprintf(1,'                               %3.6f \t %3.6f \t %3.6f ]\n',Rc_ext(3,:)');
fprintf(1,'Pixel error:           err = [ %3.5f \t %3.5f ]\n\n',err_std2); 

nz_camera = Rc_ext*[0;0;-1];
nx_camera = Rc_ext*[0;1;0];
ny_camera = Rc_ext*[1;0;0];
R1 = vrrotvec2mat(vrrotvec(nz_camera,[0;0;1]));
nz_camera = R1*nz_camera;
nx_camera = R1*nx_camera;
ny_camera = R1*ny_camera;
R2 = vrrotvec2mat(vrrotvec(nx_camera,[1;0;0]));
nz_camera = R2*nz_camera;
nx_camera = R2*nx_camera;
ny_camera = R2*ny_camera;

t = Tc_ext;
R = R2*R1;
normal = Rc_ext(:,3);

save('wall_transformation', 'R', 't', 'normal');