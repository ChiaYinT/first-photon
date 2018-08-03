function [pt, normal] = find_pt(light, virtual_light, s)
p = (virtual_light + light)/2;
normal = light - virtual_light;
normal = normal/norm(normal);

for i = 1:size(s,2),
    pt(:,i) = plane_line_intersect(normal,p,s(:,i),virtual_light);
end

end