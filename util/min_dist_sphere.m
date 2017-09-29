function [pt, distance, normal_gt, x] = min_dist_sphere(light, sensor, r, c, x0)

light = light - c;
sensor = sensor - c;


options = optimoptions('fminunc','Display', 'off', 'Algorithm','trust-region','GradObj','on');
problem.options = options;
problem.solver = 'fminunc';

if exist('x0', 'var')
    problem.x0 = x0;
else
    problem.x0 = [0;0];
end

fun = @(x) find_objective(x,light,sensor,r);
problem.objective = fun;
[x, distance] = fminunc(problem);
normal_gt = [sin(x(1))*cos(x(2)) ; sin(x(1))*sin(x(2)); cos(x(1))];
pt = r*normal_gt + c;

end


function [obj, grad] = find_objective(x,light,sensor,r)

p = r*[sin(x(1))*cos(x(2)) ; sin(x(1))*sin(x(2)); cos(x(1))];

d1 = norm(p-light);
d2 = norm(p-sensor);
obj = d1+d2;

grad = r*[cos(x(1))*cos(x(2)) cos(x(1))*sin(x(2)) -sin(x(1));...
        -sin(x(1))*sin(x(2)) sin(x(1))*cos(x(2)) 0]*( (p-light)/d1 + (p-sensor)/d2);

end