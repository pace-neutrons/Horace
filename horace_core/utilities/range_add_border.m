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
%
% Output:
% -------
%   range      Expanded range

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
