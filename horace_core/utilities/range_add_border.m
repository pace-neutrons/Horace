function range=range_add_border(range_in, tol)
% Add a small border to a range.
%
%   >> range=range_add_border(range_in)
%
% Input:
% ------
%   range_in   Range of data (2xn array)
%               [u1_min,u2_min,...;u1_max,u2_max,...]
%
%   tol         Control size of border:
%               tol=0   No border
%               tol>0   Absolute value of thickness of border
%               tol<0   Relative size as a proportion of the range along
%                       each axis. If the range is zero, absolute tol value
%                       is used.
% if tol is omitted the routine adds 4*epsilon sized border
% epsilon is the minimal number such as 1+epsilon ~=1
%
% Output:
% -------
%   range      Expanded range
%
% TODO: this function should be simlified, duplicated code, making the same 
%       things diffrently removed, unit tested and
%       moved to Herbert as it is a generic utility function

if nargin == 1 % add epsilon-sized border
    range = add_eps_border(range_in);
    return;
end

ndim=size(range_in,2);
if tol==0
    range=range_in;
    return
elseif tol>0
    range=range_in+tol*([-ones(1,ndim);ones(1,ndim)]);
elseif tol<0
    no_range=(range_in(1,:)==range_in(2,:));
    border=abs(tol*(range_in(2,:)-range_in(1,:)));
    border=[-border;border];
    range=range_in;
    range(:,~no_range)=range(:,~no_range)+border(:,~no_range);
    abs_tol = abs(tol)*([-ones(1,ndim);ones(1,ndim)]);
    range(:,no_range)  = range(:,no_range)+abs_tol(:,no_range);   
end

function range = add_eps_border(range_in)
% Add epsilon-sized border to cut limits to avoid round-off errors
sig_range = sign(range_in);
min_border = 1-4*eps*sig_range(1,:);
max_border = 1+4*eps*sig_range(2,:);
border = [min_border;max_border];
range = range_in.*border;

zero_width = abs(range_in(1,:) -range_in(2,:))<eps;
if any(zero_width) % also appropriate urange is close to zero, as 
    % large urange values are dealt with above
    center = 0.5*(range_in(1,:) -range_in(2,:));    
    min_border = center - 4*eps; 
    max_border = center + 4*eps;
    range(1,zero_width) =min_border(zero_width);
    range(2,zero_width) =max_border(zero_width);
end
