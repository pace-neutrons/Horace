function urange=range_add_border(urange_in, tol)
% Add a small border to a range.
%
%   >> urange=range_add_border(urange_in)
%
% Input:
% ------
%   urange_in   Range of data (2xn array)
%               [u1_min,u2_min,...;u1_max,u2_max,...]
%
%   tol         Control size of border:
%               tol=0   No border
%               tol>0   Absolute value of thickness of border
%               tol<0   Relative size as a proportion of the range along
%                       each axis.
%
% Output:
% -------
%   urange      Expanded range

ndim=size(urange_in,1);
if tol==0
    urange=urange_in;
    return
elseif tol>0
    urange=urange_in+tol*([-ones(1,ndim);ones(1,ndim)]);
elseif tol<0
    no_range=(urange_in(1,:)==urange_in(2,:));
    border=abs(tol*(urange_in(2,:)-urange_in(1,:)));
    border=[-border;border];
    urange=urange_in;
    urange(:,~no_range)=urange(:,~no_range)+border(:,~no_range);
end
