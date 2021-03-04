function range=range_add_border(range_in, tol)
% Add a small border to a range.
%
%   >> range=range_add_border(range_in)
%   >> range=range_add_border(range_in,tol)
%
% Input:
% ------
%   range_in   Range of data (2xn array)
%               [u1_min,u2_min,...;u1_max,u2_max,...]
%   if tol is omitted, the tol assumed to be equal -eps where eps
%   is minimal value such as 1+eps~=1;
%
%   tol         Control size of border:
%               tol=0   No border
%               tol>0   Absolute value of thickness of border
%               tol<0   Relative size as a proportion of the range along
%                       each axis. If the range is zero, absolute tol value
%                       is used.

% Output:
% -------
%   range      Expanded range
%
%
if nargin == 1 % add epsilon-sized border
    tol = -eps;
end
%
ndim=size(range_in,2);
if tol==0
    range=range_in;
    return
elseif tol>0
    range=range_in+tol*([-ones(1,ndim);ones(1,ndim)]);
    zero_width = abs(range_in(2,:)-range_in(1,:))<tol;
    if any(zero_width) % abserr for zero-width border is defined as relerr
        sig_range = sign(range_in);
        min_border = 1-tol*sig_range(1,:);
        max_border = 1+tol*sig_range(2,:);
        range(1,zero_width)=range(1,zero_width).*min_border(zero_width);
        range(2,zero_width)=range(2,zero_width).*max_border(zero_width);
    end
elseif tol<0
    tol = abs(tol);
    sig_range = sign(range_in);
    min_border = 1-tol*sig_range(1,:);
    max_border = 1+tol*sig_range(2,:);
    border = [min_border;max_border];
    range = range_in.*border;
    
    close_to_zero = abs(range_in)<tol;
    if any(close_to_zero(:)) % relerr for zero values is abserr
        % large urange values are dealt with above
        range(1,close_to_zero(1,:)) = -tol;
        range(2,close_to_zero(2,:)) = tol;
    end
end
