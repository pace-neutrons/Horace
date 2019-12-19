function [intpoints,numpoints]=shoelace_intersection_points(a1,b1,c1,d1,a2,b2,c2,d2)
%determine intersection points betweeen 2 quadrilaterals
%
%includes determining if a vertex of one quadrilateral lies within another
%
%this is a rather tedious function...
%
intpoints=[];


%first determine if points are actually inside a quadrilateral
if shoelace_inside_quad(a1,a2,b2,c2,d2)
    intpoints= [intpoints; a1];
end
if shoelace_inside_quad(b1,a2,b2,c2,d2)
    intpoints= [intpoints; b1];
end
if shoelace_inside_quad(c1,a2,b2,c2,d2)
    intpoints= [intpoints; c1];
end
if shoelace_inside_quad(d1,a2,b2,c2,d2)
    intpoints= [intpoints; d1];
end
if shoelace_inside_quad(a2,a1,b1,c1,d1)
    intpoints= [intpoints; a2];
end
if shoelace_inside_quad(b2,a1,b1,c1,d1)
    intpoints= [intpoints; b2];
end
if shoelace_inside_quad(c2,a1,b1,c1,d1)
    intpoints= [intpoints; c2];
end
if shoelace_inside_quad(d2,a1,b1,c1,d1)
    intpoints= [intpoints; d2];
end



%Now determine if the various lines defining the quadrilateral edges cross
%anywhere. If they do, then there is an intersection point.
aa = shoelace_crossing_lines(a1,b1,a2,b2);
if numel(aa) == 2
    intpoints= [intpoints; aa];
end
aa = shoelace_crossing_lines(a1,b1,b2,c2);
if numel(aa) == 2
    intpoints= [intpoints; aa];
end
aa = shoelace_crossing_lines(a1,b1,c2,d2);
if numel(aa) == 2  
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(a1,b1,d2,a2);
if numel(aa) == 2 
    intpoints = [intpoints; aa]; 
end
aa = shoelace_crossing_lines(b1,c1,a2,b2);
if numel(aa) == 2
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(b1,c1,b2,c2);
if numel(aa) == 2  
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(b1,c1,c2,d2);
if numel(aa) == 2  
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(b1,c1,d2,a2);
if numel(aa) == 2  
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(c1,d1,a2,b2);
if numel(aa) == 2 
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(c1,d1,b2,c2);
if numel(aa) == 2 
    intpoints= [intpoints; aa];
end
aa = shoelace_crossing_lines(c1,d1,c2,d2);
if numel(aa) == 2 
    intpoints= [intpoints; aa];
end
aa = shoelace_crossing_lines(c1,d1,d2,a2);
if numel(aa) == 2 
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(d1,a1,a2,b2);
if numel(aa) == 2 
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(d1,a1,b2,c2);
if numel(aa) == 2  
    intpoints= [intpoints; aa];
end
aa = shoelace_crossing_lines(d1,a1,c2,d2);
if numel(aa) == 2 
    intpoints= [intpoints; aa]; 
end
aa = shoelace_crossing_lines(d1,a1,d2,a2);
if numel(aa) == 2 
    intpoints= [intpoints; aa];
end

if isempty(intpoints)
    numpoints=0;
else
    numpoints=numel(intpoints)/2;
end