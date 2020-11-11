function intpoints=shoelace_check_in_quad(a1,b1,c1,d1,a2,b2,c2,d2)
%
% Check if 2 bins overlap at all.
%

intpoints=[];
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
