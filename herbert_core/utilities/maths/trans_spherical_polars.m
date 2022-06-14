function tmat=trans_spherical_polars(phi,theta)
% Given a vector V with components x1,x2,x3 in reference frame S, returns the matrix TMAT such that
%	y(i) = tmat(i,j)*x(j)
% are the coordinates of the same vector in the reference frame S' which is related
% to S by rotation PHI about z followed by THETA about the resulting y axis.
%
%   >> tmat=trans_spherical_polars(phi,theta)
%
%   phi, theta      Vectors of spherical polar angles (rad)
%   tmat            3 x 3 x m array of tranformation matricies

cp = cos(phi(:)');
sp = sin(phi(:)');
ct = cos(theta(:)');
st = sin(theta(:)');

tmat = reshape([ct.*cp; -sp; st.*cp; ct.*sp; cp; st.*sp; -st; zeros(1,numel(phi)); ct], [3,3,numel(phi)]);
