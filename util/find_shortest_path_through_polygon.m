function [point, d_plane] = find_shortest_path_through_polygon(light, x, vertex)

point = zeros(3, size(vertex,2));
d_plane = zeros(1, size(vertex,2));
for i = 1:size(vertex,2) - 1,
    p1 = vertex(:,i);
    p2 = vertex(:,i + 1);
    [point(:,i), d_plane(1,i)] = find_shortest_path_through_edge(light, x, p1, p2);
end

p1 = vertex(:,size(vertex,2));
p2 = vertex(:,1);
[point(:,size(vertex,2)), d_plane(1,size(vertex,2))] = find_shortest_path_through_edge(light, x, p1, p2);

[d_plane,I] = min(d_plane);
point = point(:,I);

end

function  [point, d_plane] = find_shortest_path_through_edge(light, x, p1, p2)

line_width = norm(p2-p1);


[xout,yout] = circcirc(0,0,norm(light-p1),line_width,0,norm(light-p2));
v1 = [xout(1) abs(yout(1))];
[xout,yout] = circcirc(0,0,norm(x-p1),line_width,0,norm(x-p2));
v2 = [xout(1) -abs(yout(1))];

v = v1 - v2;
alpha = - v2(2)/v(2);
p = v2 + alpha* v;

if p(1) < 0,
    point = p1;
elseif p(1) > line_width
    point = p2;
else
    alpha = norm(p) /line_width;
    point = alpha*p2 + (1-alpha)*p1;
end

d_plane =  norm(point - light) + norm(point - x);

end