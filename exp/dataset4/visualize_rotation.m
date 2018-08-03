clear; clc; close all;
addpath('../../reconstruction');
output_folder = 'RotatingInY-quadratic/';

acquisition_time = [20, 40, 100, 200, 400, 1000, 2000, 4000, 10000];
T = 100;
C = hsv(T);
for a = 1:length(acquisition_time)
    normal = nan(3,T);
    %figure; hold on;
    for test = 1:T
        result_file = [output_folder num2str(a, '%02d') '_' num2str(test, '%02d') '.mat'];
        load(result_file);

        if isempty(best_fit)
            continue;
        end
        
        if isnan(best_fit(1))
            best_fit(6) = -abs(best_fit(6));
            recovered_pt = best_fit(4:6,1);
            normal(:,test) = nan(3,1);
        else
            best_fit(3) = -abs(best_fit(3));
            [recovered_pt, normal(:,test)] = find_pt(light, best_fit(1:3,1), sensor(:,best_inlier));
        
        end
        %plot3(recovered_pt(1,:), recovered_pt(2,:), recovered_pt(3,:), '.', 'color', C(test,:));
        
    end
    angle = acosd(normal'*[0;0;1]);
    figure;
    x = (1:length(angle))*acquisition_time(a)/1000;
    plot(x, angle, 'bo-');
    set(gca, 'Fontsize', 18);
    ylim([0 90]);
    xlim([x(1) x(end)]);
   
end
