function prob = probability_of_point(x,M,x0,norm_flag)
% Calculate exp( -(x-x0)'*M*(x-x0) ) for the dD column vectors x and x0 and
% the (d,d) square matrix M.
% If x is a (d,n) array of n d-dimensional points scale-up M and x0
% appropriately in order to take advantage of mtimesx_horace.

% Inputs:
%   x       The d-dimensional test point(s).
%           Either a (d,1) vector for a single point, or a (d,n) matrix for
%           n points.
%
%   M       The d-dimensional gaussian width matricies, where the elements 
%           of M describe the semi-axis lengths by M_ij = 1/sigma_ij^2 
%           Either a (d,d) matrix for a single ellipsoid or a (d,d,m) array
%           for m ellipsoids.
%
%   x0      The centre(s) of the matricies.
%           Either a (d,1) vector for a single point, or a (d,m) matrix for
%           m ellipsoids.

% Outputs:
%   prob    The value of the d-dimensional gaussian evaluated at x

% Verify that inputs are sensible:
if nargin < 4 || isempty(norm_flag) || ~islogical(norm_flag)
    norm_flag = false;
end
if ~ismatrix(x)
    error('x must be a (d,1) point or a (d,n) collection of n points')
end
if size(x,1)==1 && size(x,2)>1
    warn('x is (1,d) instead of (d,1)')
    x=x';
end
[d,n]=size(x);
if n==0
    prob = 0;
    return
end
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
    error('x0 must be (%d,%d) for %d ellipsoid(s) and %d-dimensional point input',d,m,m,d)
end

% Permute the dimensions of x and x0 in preparation for mtimesx
x = permute(x, [1,3,4,2]);  % (d,1,1,n)
x0= permute(x0,[1,3,2]);    % (d,1,m,1) where the last 1 is implicit
% subtract each x0 from each x
v = bsxfun(@minus,x,x0);    % (d,1,m,n)

% calculate the normalizing constant 
norm = ones(m,1);
if norm_flag
    pid2 = (2*pi)^(d/2);
    for i=1:m
        norm(i) = 1/( pid2* sqrt(det(M(:,:,i))) );
    end    
end
% scale-up M from (d,d,m) to (d,d,m,n) for mtimesx
M = repmat(M,[1,1,1,n]);
% and the normalization constant too, for good measure
norm = permute(repmat(norm,[1,n]),[2,1]); % (n,m)

if m==1 && n==1
    vMv = sum(v .* (M*v));
else
    Mv = mtimesx_horace(M,v); % (d,d,m,n)*(d,1,m,n) -> (d,1,m,n)
    vMv = squeeze(sum( v .* Mv, 1));   % (1,d,m,n)*(d,1,m,n) -> (1,1,m,n) -> (m,n)
end
prob = exp( -vMv/2 ); % (m,n) {unless if m=1, then it's (n,1)}
if m>1
    % ensure that the output is (n,m)
    prob = permute(prob,[2,1]); 
end
prob = norm .* prob; % (n,m).*(n,m)->(n,m)
end

