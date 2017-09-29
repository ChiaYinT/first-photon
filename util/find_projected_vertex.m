function projected_vertex = find_projected_vertex(plane_vertex, light, projected_plane_normal)
if ~exist('projected_plane_normal', 'var')
    projected_plane_normal = [0;0;1];
end
projected_vertex = zeros(size(plane_vertex));
for i = 1:size(plane_vertex,2),
     [projected_vertex(:,i),check]=plane_line_intersect(projected_plane_normal,[0; 0;0],light,plane_vertex(:,i));
end
end
