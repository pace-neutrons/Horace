function [m_in_n, allVxR] = point_in_ellipsoid_with_prob(x,M,C,x0,frac)
% Determine if a point (or points) x is inside of the ellipsoid defined by
% M centered at x0.

% Inputs:
%   x       The d-dimensional test point(s).
%           Either a (d,1) vector for a single point, or a (d,n) matrix for
%           n points.
%
%   M       The d-dimensional gaussian width matricies, where the elements 
%           of M describe the semi-axis lengths by M_ij = 1/sigma_ij^2 
%           Either a (d,d) matrix for a single ellipsoid or a (d,d,m) array
%           for m ellipsoids.
%   C       The d-dimensional covariance matricies ( the inverse of M)
%           Either a (d,d) matrix for a single ellipsoid or a (d,d,m) array
%           for m ellipsoids.
%
%   x0      The centre(s) of the matricies.
%           Either a (d,1) vector for a single point, or a (d,m) matrix for
%           m ellipsoids.

% Outputs:


% Verify that inputs are sensible:
if nargin<4 || isempty(frac)
    frac = 0.5;
end
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

% A normalized d-dimensional Gaussian is:
%       exp( - (x-x0)'*M*(x-x0)/2 )     exp( - (x-x0)'*M*(x-x0)/2 )
%    ------------------------------- == ---------------------------
%      (2pi)^(d/2)*sqrt(det(inv(M)))      (2pi)^(d/2)*sqrt(det(C))
pid2 = (2*pi)^(d/2);

m_in_n = cell(m,1);
allVxR = cell(m,1);
% Faster than any other tested method:
for j=1:m
    v = bsxfun(@minus,x,x0(:,j)); % (d,n)
    vMv = sum( v .* mtimesx_horace( M(:,:,j), v), 1); % (d,n).*( (d,d)*(d,n) ) => (d,n); sum( (d,n), 1) => (1,n)
    VxR = exp(-vMv/2);
    p = VxR / (pid2*sqrt(det(C(:,:,j))));
    m_in_n{j} = find( p >= frac, n);
    if numel(m_in_n{j})>0
        allVxR{j} = VxR(m_in_n{j});
    end
end
end
