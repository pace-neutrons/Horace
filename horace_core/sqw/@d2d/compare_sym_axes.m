function [speedup,midpoint]=compare_sym_axes(win,v1,v2,v3)
%
% Determine whether the reflection plane specified during d2d symmetrisation
% is a plane perpendicular to the data plane containing one of the data
% axes (i.e. the reflection required is up/down or right/left).
%

%win=sqw(win); 
midpoint=[]; speedup=false;
%getin=get(win);%for debug.

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

%If we can achieve a speedup then normvec will be one of the data axes, and
%the other will be either v1 or v2.

datavec1=win.data_.u_to_rlu([1:3],win.data_.pax(1));
datavec2=win.data_.u_to_rlu([1:3],win.data_.pax(2));

if xor(all(abs(cross(normvec,datavec1))<1e-5),all(abs(cross(normvec,datavec2))<1e-5))
    %tells us that normvec is parallel / antiparallel to ONE of the data
    %axes. Implicitly catches the case where normvec=[0,0,0]
    speedup=true;
elseif (all(cross(normvec,datavec1)<1e-5)) && all(datavec2<1e-5)
    %There is another case that we must deal with, where one of the axes is
    %energy, since the cross product above will be zero for both parts of the
    %xor statement.
    speedup=true;
elseif (all(cross(normvec,datavec2)<1e-5)) && all(datavec1<1e-5)
    speedup=true;
end


if speedup
    %must now work out what the midpoint is.
    if all(cross(normvec,datavec1)<1e-5) && any(datavec1>1e-5)
       v3new=inv(win.data_.u_to_rlu([1:3],[1:3]))*v3;
       firstx=v3new(win.data_.pax(1));
       midpoint=[firstx,NaN];
    elseif all(cross(normvec,datavec2)<1e-5) && any(datavec2>1e-5)
       v3new=inv(win.data_.u_to_rlu([1:3],[1:3]))*v3;
       firsty=v3new(win.data_.pax(2));
       midpoint=[NaN,firsty];
    else
        error('Horace error: symmetrisation logic flaw. Contact R. Ewings');
    end
end

