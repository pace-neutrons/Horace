function [ok,mess]=test_symmetrisation_plane(win,v1,v2,v3)
%
% Fnction to test whether specified symmetrisation plane is actually
% perpendicular to the plane of a d2d object. If not, ok=false.

win=sqw(win);

ok=false;%declare outputs
mess='Horace error: symmetrisation plane specified is not perpendicular to the data plane';

if size(v1)==[1,3]
    v1=v1';
end
if size(v2)==[1,3]
    v2=v2';
end
if size(v3)==[1,3]
    v3=v3';
end

normvec=cross(v1,v2);

datavec1=win.data.u_to_rlu([1:3],win.data.pax(1));
datavec2=win.data.u_to_rlu([1:3],win.data.pax(2));

datanorm=cross(datavec1,datavec2);

%make use of the fact that 2 planes are perpendicular if their normal
%vectors are perpendicular:
dotprod=dot(normvec,datanorm);
if abs(dotprod)<1e-5
    ok=true;
end

if ok
    mess=''; 
end

