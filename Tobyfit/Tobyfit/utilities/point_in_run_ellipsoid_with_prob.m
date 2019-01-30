function [m_in_n, allVxR] = point_in_run_ellipsoid_with_prob(x,x_run,M,vol,x0,x0_run,frac)
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
%   vol     The volume of the resolution function (1,m)
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

m_in_n = cell(m,1);
allVxR = cell(m,1);
% Faster than any other tested method:
for j=1:m
    same_run = x_run == x0_run(j); %(1,n)
    if any(same_run)
%         fprintf('\t%4d points with same run index as pixel %4d\n',sum(same_run),j)
        v = bsxfun(@minus,x(:,same_run),x0(:,j)); % (d,sr<=n)
        
        Mv = mtimesx_horace( M(:,:,j), v); % (d,d)*(d,sr) => (d,sr)
        
        vMv = sum( v .* Mv, 1); % (d,sr).*(d,sr) => (d,sr); sum( (d,sr), 1) => (1,sr)
        VxR = exp(-vMv/2);
        in_res = VxR >= frac*vol(j); %(1,sr)
        same_run_idx = find( same_run, n); % (1,sr);
        m_in_n{j} = same_run_idx(in_res);
        if numel(m_in_n{j})>0
            allVxR{j} = VxR(in_res);
        end
    end
end
end

% function Mv=M_times_v(M,v,d,n)
% Mv=zeros(d,n);
% for k=1:n
%     for j=1:d
%         % This should be M(j,:)' but M is symmetric
%         Mv(j,k) = sum( M(:,j) .* v(:,k) );
% %         Mv(j,k) = sum( M(j,:)' .* v(:,k), 1);
%     end
% end
% end
