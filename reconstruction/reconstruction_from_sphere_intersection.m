function [n, p] = reconstruction_from_sphere_intersection(s, l, distance, X, Y, Z)

[virtual_light] = find_virtual_light(s,distance,X,Y,Z);
[p, n] = find_pt(l, virtual_light, s(:,1));

end


function [pt, normal] = find_pt(light, virtual_light, s)
p = (virtual_light + light)/2;
normal = light - virtual_light;
normal = normal/norm(normal);
[pt]=plane_line_intersect(normal,p,s,virtual_light);
end

function [virtual_light] = find_virtual_light(s,dist,X,Y,Z)

obj = zeros(size(X));
for i = 1:size(s,2),
    d = sqrt((X - s(1,i)).^2 + (Y -s(2,i)).^2  + (Z-s(3,i)).^2);
    obj = (d - dist(i)).^2 + obj;
end

[tmp,I] = sort(obj(:));
[a,b,c] = ind2sub(size(X), I);

fun = @(x) find_virtual_light_obj(x,s,dist);
options = optimoptions('fminunc', 'Display', 'off','Algorithm','trust-region','GradObj','on') ;
problem.options = options;
problem.objective = fun;
problem.solver = 'fminunc';


idx = 1;
tmp_virtual_light = [X(a(idx),b(idx),c(idx));...
                     Y(a(idx),b(idx),c(idx));...
                     Z(a(idx),b(idx),c(idx))];
problem.x0 = tmp_virtual_light;
[virtual_light] = fminunc(problem);    

end


function [obj, grad] = find_virtual_light_obj(x,camera,dist)

obj = 0;
grad = zeros(size(x));
for i = 1:size(camera,2),
    c = camera(:,i);
    d = norm(x-c);
    obj = (d - dist(i))^2 + obj;
    grad = grad + 2*(d-dist(i)) * (x-c)/d;
end
end
