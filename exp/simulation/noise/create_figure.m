clear; clc; close all;

date_folder = '0127';
load(['error-quadratic/' date_folder]);
E_p_q = E_p;
E_n_q = E_n;
load(['error/' date_folder]);
load(['../../../simulation/setup/' date_folder]);
load(['../../../simulation/first_photon_iter/' date_folder]);

load('ground_truth_1116');

speed_of_light = 299792458;
exposure = pinhole_camera.exposure*10^-12;

simulation = 4:4:32;
neighbor = 5:5:15;

curve_color = hsv(5);
legend_text = {};

average_tof_error = nan(size(simulation,2),size(neighbor,2)+1);
 
for sim_it = 1:size(simulation,2),
    num_simulation = simulation(sim_it);
    idx = randperm(size(first_photon_iter,2), num_simulation);
    for neighbor_it = 1 : size(neighbor,2)+1,
        fprintf('%d %d\n', sim_it, neighbor_it);
        first_photon = min(first_photon_iter(:,idx), [], 2)';
        rendered_tof = first_photon*exposure;
        average_tof_error(sim_it, neighbor_it) = nanmean(rendered_tof - tof_gt);
    end
end


figure; hold on;

plot(average_tof_error(:,1)*speed_of_light, E_p(:,1), 's--', 'color', curve_color(1,:), 'MarkerSize', 10, 'LineWidth', 3);
plot(average_tof_error(:,2)*speed_of_light, E_p(:,2), '*:', 'color', curve_color(2,:), 'MarkerSize', 10, 'LineWidth', 3);
plot(average_tof_error(:,3)*speed_of_light, E_p(:,3), '^-.', 'color', curve_color(3,:), 'MarkerSize', 10, 'LineWidth', 3);
plot(average_tof_error(:,4)*speed_of_light, E_p_q, 'o-', 'color', curve_color(4,:), 'MarkerSize', 10, 'LineWidth', 3);


for i = 1:size(E_p,2),
    legend_text{i,1} = ['neighborhood size = ' num2str(neighbor(i))];
end
plot([0 max(average_tof_error(:))*speed_of_light],[0 max(average_tof_error(:))*speed_of_light], 'k.--', 'MarkerSize', 20, 'LineWidth', 3);
legend(legend_text{1:3}, 'union of quadratic',  'baseline');
set(gca,'FontSize',18);
set(gca,'XTick',0:0.003:0.02);


figure; hold on;

plot(average_tof_error(:,1)*speed_of_light, E_n(:,1), 's--', 'color', curve_color(1,:), 'MarkerSize', 10, 'LineWidth', 3);
plot(average_tof_error(:,2)*speed_of_light, E_n(:,2), '*:', 'color', curve_color(2,:), 'MarkerSize', 10, 'LineWidth', 3);
plot(average_tof_error(:,3)*speed_of_light, E_n(:,3), '^-.', 'color', curve_color(3,:), 'MarkerSize', 10, 'LineWidth', 3);
plot(average_tof_error(:,4)*speed_of_light, E_n_q, 'o-', 'color', curve_color(4,:), 'MarkerSize', 10, 'LineWidth', 3);


for i = 1:size(E_p,2),
    legend_text{i,1} = ['neighborhood size = ' num2str(neighbor(i))];
end
legend(legend_text{1:3}, 'union of quadratic');
set(gca,'FontSize',18);
xlim([0 0.018])
set(gca,'XTick',0:0.003:0.016);

return
load('recovery_quadratic/0127_32');

figure; hold on;

[NLOS_x,NLOS_y,NLOS_z] = sphere;
nlos_handler = surf(NLOS_x*sphere_r+sphere_c(1), NLOS_y*sphere_r+sphere_c(2), NLOS_z*sphere_r + sphere_c(3),'EdgeColor',[255 215 0]/255 *0.8 , 'FaceColor', [255 215 0]/255);
alpha(nlos_handler,.5);

plot3(recovered_pt(1,:), recovered_pt(2,:), recovered_pt(3,:), 'b.', 'MarkerSize', 10); 


view(-96,-42);
axis equal
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);

axis off;

figure; hold on;
[NLOS_x,NLOS_y,NLOS_z] = sphere;
nlos_handler = surf(NLOS_x*sphere_r+sphere_c(1), NLOS_y*sphere_r+sphere_c(2), NLOS_z*sphere_r + sphere_c(3),'EdgeColor',[255 215 0]/255 *0.8 , 'FaceColor', [255 215 0]/255);
alpha(nlos_handler,.5);
plot3(recovered_pt(1,:), recovered_pt(2,:), recovered_pt(3,:), 'b.'); 

length = 0.5;
for i = 1:size(recovered_normal,2),
    color_arrow = [recovered_normal(3,i);recovered_normal(1,i);recovered_normal(2,i)]/2 + 0.5 ;
    quiver3(recovered_pt(1,i), recovered_pt(2,i), recovered_pt(3,i), length*recovered_normal(1,i),length*recovered_normal(2,i),length*recovered_normal(3,i), 'color', color_arrow, 'LineWidth', 3, 'MaxHeadSize', 0.5);
    
end
view(-96,-42);
axis equal
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);

axis off;



return
load('recovery/0127_4_5');

figure; hold on;

[NLOS_x,NLOS_y,NLOS_z] = sphere;
nlos_handler = surf(NLOS_x*sphere_r+sphere_c(1), NLOS_y*sphere_r+sphere_c(2), NLOS_z*sphere_r + sphere_c(3),'EdgeColor',[255 215 0]/255 *0.8 , 'FaceColor', [255 215 0]/255);
alpha(nlos_handler,.5);

plot3(recovered_p(1,:), recovered_p(2,:), recovered_p(3,:), 'b.', 'MarkerSize', 10); 


view(-96,-42);
axis equal
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);

axis off;

figure; hold on;
[NLOS_x,NLOS_y,NLOS_z] = sphere;
nlos_handler = surf(NLOS_x*sphere_r+sphere_c(1), NLOS_y*sphere_r+sphere_c(2), NLOS_z*sphere_r + sphere_c(3),'EdgeColor',[255 215 0]/255 *0.8 , 'FaceColor', [255 215 0]/255);
alpha(nlos_handler,.5);
plot3(recovered_p(1,:), recovered_p(2,:), recovered_p(3,:), 'b.'); 

length = 0.5;
for i = 1:size(recovered_n,2),
    color_arrow = [recovered_n(3,i);recovered_n(1,i);recovered_n(2,i)]/2 + 0.5 ;
    quiver3(recovered_p(1,i), recovered_p(2,i), recovered_p(3,i), length*recovered_n(1,i),length*recovered_n(2,i),length*recovered_n(3,i), 'color', color_arrow, 'LineWidth', 3, 'MaxHeadSize', 0.5);
    
end
view(-96,-42);
axis equal
xlim([-1.5 1.5]);
ylim([-1.5 1.5]);

axis off;