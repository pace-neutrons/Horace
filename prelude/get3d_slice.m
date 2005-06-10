function [v,x,y,z] = get3d_slice (data, pax, pax_lo, pax_hi, p1_lo, p1_hi, p2_lo, p2_hi, p3_lo, p3_hi, imin, imax,s);
% Take a 3D section from 4D grid data, and output the arrays needed for sliceomatic
%
% e.g. to get a volume in (k,l,e) corresponding to -0.2 =< h < 0.2:
%   >> [v,x,y,z] = get3d_slice (data, 1, -0.2, 0.2, -1.5, 1.5, -2, 2, 1, 11)
%   >> sliceomatic (v,y,x,z)

[xv,yv,zv,ri] = gridproj_3d(data,pax,pax_lo,pax_hi);
lx = find(xv>=p1_lo & xv<p1_hi);
ly = find(yv>=p2_lo & yv<p2_hi);
lz = find(zv>=p3_lo & zv<p3_hi);
ri(find(ri<imin)) = imin;
ri(find(ri>imax)) = imax;
v = ri(lx,ly,lz);

% nb/ slice-o-matic takes data v(x1,x2,x3) but requires the call:
    %   >> sliceomatic (v,x2,x1,x3)
if nargin==13 & s=='i',
    %for using isosurfaces in slice-o-matic. This requires x, y, z to have the same size as 
    % the equivalent directions in v. Slice-o-matic will add one additional bin to the data 
    % as to make the data in x, y, z bin boundaries. This is the only way for now to make the
    % isosurface option to work.
    x = xv(lx(1):lx(end));
    y = yv(ly(1):ly(end));
    z = zv(lz(1):lz(end));
else
    % For corrctly slicing in slice-o-matic: provide bin boundaries
    x = xv(lx(1):lx(end)+1);
    y = yv(ly(1):ly(end)+1);
    z = zv(lz(1):lz(end)+1);
end
