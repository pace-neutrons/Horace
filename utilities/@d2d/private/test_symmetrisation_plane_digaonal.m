function [diag,type]=test_symmetrisation_plane_digaonal(win,v1,v2,v3)
%
% Test the symmetrisation plane specified to see if it is a diagonal of the
% input object. If so then we do not have to use the shoelace algorithm,
% which is an advantage because it is rather slow.
%
% RAE 13/1/10
%

win=sqw(win);

%declare output:
diag=false; type=0;

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

%now calculate the angle between the normal to the symmetrisation plane and
%each of the two data vectors. If it is 45 degrees in both cases then we
%have a diagonal.
angle1=acos(dot(normvec,datavec1) ./ ((sqrt(sum(datavec1.^2))).*(sqrt(sum(normvec.^2)))));
angle2=acos(dot(normvec,datavec2) ./ ((sqrt(sum(datavec2.^2))).*(sqrt(sum(normvec.^2)))));

val=pi*45/180;

angle1=1e-7*(round(1e7*angle1)); angle2=1e-7*(round(1e7*angle2));
val=1e-7*(round(1e7*val));%do this to avoid rounding errors.

ppi=1e-7*(round(1e7*pi));%do the same with the value of pi!!!

if (angle1==val || angle1==-1*val || angle1==val+ppi || angle1==ppi-val) ...
        && (angle2==val || angle2==-1*val || angle2==val+ppi || angle2==ppi-val)
    diag=true;
end

if diag
    %determine what kind of diagonal plane we are dealing with (i.e. x->y,
    %or x->-y).
    [R,trans] = calculate_transformation_matrix(win,v1',v2',v3');
    test=R*[1;0;0];
    test=1e-5*round(1e5*test);%bloody rounding errors again!!!!
    if isequal(test,1e-5*round(1e5*[0;-1;0]))
        type=2;
    elseif isequal(test,1e-5*round(1e5*[0;1;0]))
        type=1;
    end
    %
end



