function area=shoelace_triangle_area(a,b,c)
%
%shoelace algorithm for a triangle.
%

area= 0.5.* abs( a(1)*b(2) + b(1)*c(2) + c(1)*a(2) - a(2)*b(1) - b(2)*c(1) - c(2)*a(1));