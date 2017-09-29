function virtual_light = find_mirror_position(light, plane_normal, plane_p)
v = light - plane_p;
virtual_light = plane_p + v - 2*v'*plane_normal*plane_normal;
end