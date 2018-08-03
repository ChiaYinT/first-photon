function [distance_gt, contributing_pt, normal_gt, x] = find_longest_path_sphere(light, sensor, sphere_c, sphere_r, x0)

light = light - sphere_c;
sensor = sensor - sphere_c;

options = optimoptions('fminunc', 'Display', 'off','Algorithm','trust-region','GradObj','on') ;
problem.options = options;
problem.solver = 'fminunc';
if exist('x0', 'var')
    problem.x0 = x0;
else
    problem.x0 = [0; 0];
end

fun = @(x)  find_scene_pt_obj(x,light,sensor,sphere_r);
problem.objective = fun;
[x, distance_gt] = fminunc(problem);
normal_gt = [cos(x(1))*cos(x(2)); cos(x(1))*sin(x(2)); -sin(x(1))];
contributing_pt = sphere_r*normal_gt + sphere_c;
 
end


function [obj, grad] = find_scene_pt_obj(x, light, camera, R)

p = R*[cos(x(1))*cos(x(2)); cos(x(1))*sin(x(2)); -sin(x(1))];

d1 = norm(p - light);
d2 = norm(p - camera);
obj = -(d1 + d2);
grad = -R*[-sin(x(1))*cos(x(2)) -sin(x(1))*sin(x(2)) -cos(x(1));...
          -cos(x(1))*sin(x(2)) cos(x(1))*cos(x(2)) 0] * ((p-light)/d1 + (p-camera)/d2);

end
