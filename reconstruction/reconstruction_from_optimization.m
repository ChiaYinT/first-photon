function [n, p] = reconstruction_from_optimization(s, l, distance, option)

% planar assumption
fun = @(x) find_obj(x,s,distance);
options = optimoptions('fminunc', 'Display', 'off','Algorithm','trust-region','GradObj','on') ;
problem.options = options;
problem.objective = fun;
problem.solver = 'fminunc';

if isfield(option, 'l0')
    l0 = option.l0;
else
    l0 = nan(3,1);
end

if isnan(l0(1))
    problem.x0 = [0;0;100];
else
    problem.x0 = l0;
end
[virtual_light] = fminunc(problem);    
virtual_light(3) = option.z_direction*abs(virtual_light(3));
[p, n] = find_pt(l, virtual_light, s(:,1));

% %point assumption
% fun2 = @(x) find_obj_point(x,s,l,distance);
% problem.objective = fun2;
% problem.solver = 'fminunc';
% 
% if isnan(x0(1))
%     problem.x0 = [0;0;50];
% else
%     problem.x0 = x0;
% end
% [scene_point, obj_point] = fminunc(problem);    
% 
% if obj_point < obj_plane,
%     p = scene_point;
%     n = nan(3,1);
% end
end

function [obj, grad] = find_obj_point(x, s, l, distance)
obj = 0;
grad = zeros(3,1);

d0 = norm(x - l);
v = (x-l)/d0;
for i = 1:size(s,2),
    dist_est = norm(x-s(:,i)) ;
    obj = obj + (dist_est + d0 - distance(i))^2;
        
    grad = grad + 2*(dist_est + d0 - distance(i))*((x-s(:,i))/dist_est + v);        
end

end

function [obj, grad] = find_obj(x, s, distance)
obj = 0;
grad = zeros(3,1);

for i = 1:size(s,2),
    dist_est = norm(x-s(:,i));
    obj = obj + (dist_est - distance(i))^2;
    grad = grad + 2*(dist_est - distance(i))*(x-s(:,i))/dist_est;        
end

end


function [pt, normal] = find_pt(light, virtual_light, s)
p = (virtual_light + light)/2;
normal = light - virtual_light;
normal = normal/norm(normal);
pt = plane_line_intersect(normal,p,s,virtual_light);

end