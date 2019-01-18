function m_in_n = point_in_ellipsoid_as_cells_new(x,M,x0)
% Determine if a point (or points) x is inside of the ellipsoid defined by
% M centered at x0.

% Inputs:
%   x       The d-dimensional test point(s).
%           Either a (d,1) vector for a single point, or a (d,n) matrix for
%           n points.
%
%   M       The d-dimensional ellipsoid matricies, where the elements of M
%           describe the semi-axis lengths by M_ij = 1/a_ij^2 as
%           (x-x0)'*M*(x-x0)=1 ==> x_1^2/a_11^2 + ... = 1 
%           is the description of an ellipsoid in d dimensions.
%           Either a (d,d) matrix for a single ellipsoid or a (d,d,m) array
%           for m ellipsoids.
%
%   x0      The centre(s) of the matricies.
%           Either a (d,1) vector for a single point, or a (d,m) matrix for
%           m ellipsoids.

% Outputs:


% Verify that inputs are sensible:
if ~ismatrix(x)
    error('x must be a (1,d) point or a (n,d) collection of n points')
end
[d,n]=size(x);
%
if ismatrix(M) && any(size(M)~=[d,d])
    error('M must be (%d,%d) for %d-dimensional point input',d,d,d)
elseif ndims(M) == 3 && (size(M,1)~=d||size(M,2)~=d)
    error('M must be (%d,%d,n) for %d-dimensional point input',d,d,d)
elseif ndims(M)>3 || ndims(M)<2
    error('M must be a 2 or 3 dimensional array')
end
if ismatrix(M)
    m=1;
else
    m=size(M,3);
end
%
if any(size(x0)~=[d,m])
    error('x0 must be (%d,%d) for %d ellipsoid(s) and %d-dimensional point input',d,m,d,m)
end

m_in_n = cell(m,1);
% Faster than any other tested method:
for j=1:m
    v = bsxfun(@minus,x,x0(:,j)); % (d,n)
    vMv = sum( v .* mtimesx_horace( M(:,:,j), v), 1); % (d,n).*( (d,d)*(d,n) ) => (d,n); sum( (d,n), 1) => (1,n)
    m_in_n{j} = find( vMv <= 1, n);
end
end
