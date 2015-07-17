function [qe1,qe2] = hkle(w,x)
% [h,k,l,e] for points in the coordinates of the display axes for an sqw object from a single spe file
%
%   >> [qe1,qe2] = hkle(w,x)
%
% Input:
% ------
%   w       sqw object
%   x       Vector of coordinates in the display axes of an sqw object
%           The number of coordinates must match the dimensionality of the object.
%          e.g. for a 2D sqw object, x=[x1,x2], where x1, x2 are column vectors.
%           More than one point can be provided by giving more rows
%          e.g.  [1.2,4.3; 1.1,5.4; 1.32, 6.7] for 3 points from a 2D object.
%           Generally, an (n x nd) array, where n is the number of points, nd
%          the dimensionality of the object.
%
% Output:
% -------
%   qe1     Components of momentum (in rlu) and energy for each bin in the dataset
%           Generally, will be (n x 4) array, where n is the number of points
%
%   qe2     For the second root

% Check input
% ----------------
% Conversion only possible if 1D sqw-type object
if ~is_sqw_type(w(1))
    error('Function defined only for sqw-type')
end
    
% Check only one spe file
if ~(w.main_header.nfiles==1)
    error('Function defined only for sqw object with just one contributing .spe file')
end

% Check direct or indirect geometry
if ~(w.header.emode==1||w.header.emode==2)
    error('sqw object must contain inelastic data (direct or indirect geometry)')
end

% Check dimensionality of points array
nd = dimensions(w);
if nd==1 && isvector(x)    % we'll accept a row vector of values for 1D case only
    x=x(:); % guarantee is a column
end
if ~isnumeric(x)||numel(size(x))~=2||size(x,2)~=nd
    error('Check size of coordinate array')
else
    np=size(x,1);
    if np<1
        qe1=[];
        qe2=[];
        return
    end
end

% Check one and only one integration range with infinite or semi-infinite range
unknown_axis=0;
for i=1:length(w.data.iax)
    if ~(isfinite(w.data.iint(1,i)) && isfinite(w.data.iint(2,i)))
        unknown_axis=unknown_axis+1;            
    end
end
if unknown_axis~=1
    error('One and only one integration axis must have infinite or semi-infinite range')
end

[qe1,qe2]=calculate_qw_points(w,x);
