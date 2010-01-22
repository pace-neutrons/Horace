function inside = shoelace_inside_quad(p,a,b,c,d)
% p is the coordinates of a test point
%a, b, c, and d are the vertices of the quadrilateral

a_quad = shoelace_triangle_area(a,b,c) + shoelace_triangle_area(c,d,a);
aa=shoelace_triangle_area(p,a,b);
ab=shoelace_triangle_area(p,b,c);
ac=shoelace_triangle_area(p,c,d);
ad=shoelace_triangle_area(p,d,a);

% if abs(aa + ab + ac + ad - a_quad) < 1e-5
%     inside=true;
% else
%     inside=false;
% end

inside=(abs(aa + ab + ac + ad - a_quad) < 1e-5);