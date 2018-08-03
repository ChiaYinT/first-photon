clear; clc; close all;
addpath('../../reconstruction');
addpath('../../util');

output_folder = 'MovingInX-quadratic/';

%output_folder = 'MovingInZ-quadratic/';
acquisition_time = [20, 40, 100, 200, 400, 1000, 2000, 4000, 10000]+120;
T = 100;
C = hsv(T);
for a = 1:length(acquisition_time)
    intercept = nan(T,1);
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
  
         if strcmp(output_folder, 'MovingInZ-quadratic/') == 1
             intercept(test) = -((0.82-recovered_pt(1,1))*normal(1,test) + (-0.1-recovered_pt(2,1))*normal(2,test))/normal(3,test) + recovered_pt(3,1);
         else
             intercept(test) = -((-.36-recovered_pt(2,1))*normal(2,test) + (-.95-recovered_pt(3,1))*normal(3,test))/normal(1,test) + recovered_pt(1,1);
         end
         
  
    end
    

    figure;
    x = (1:length(intercept))*acquisition_time(a)/1000;
    plot(x, intercept, 'bo-');
    set(gca, 'Fontsize', 18);
    %ylim([-1 0.1]);
    %xlim([x(1) x(end)]);
    axis tight
    d = (normal'*normal);
    max(acosd(d(:)))
end
