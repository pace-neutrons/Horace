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
%   if tol is omitted, the tol assumed to be equal to -eps
%   where eps is minimal value such as 1+eps~=1;
%
%   tol         Control size of border:
%               tol=0   No border
%               tol>0   Absolute value of thickness of border. If range is
%                       zero and tol is small, so that range(i)+tol ==
%                       range(i), relative tol value is used.
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
if size(range_in,2)>4 % add border for first 4 ranges only
    range_store = range_in;
    range_in = range_in(:,1:4);
else
    range_store = [];    
end
%
ndim=size(range_in,2);
if tol==0
    range=range_in;
    return
end
if isnumeric(tol) && tol>0
    range=range_in+tol*([-ones(1,ndim);ones(1,ndim)]);
    % ensure smoothness -- range smaller then 2*tol remains 2*toll
    zero_width = abs(range_in(2,:)-range_in(1,:))<2*tol;
    if any(zero_width) % absolute range for zero-width border redefined as relative
        %
        rel_range = get_relative_range(range_in,tol);
        range(:,zero_width) = rel_range(:,zero_width);
    end
elseif tol<0
    tol = abs(tol);
    range = get_relative_range(range_in,tol);
        
    close_to_zero = abs(range_in)<tol;
    if any(close_to_zero(:)) % relative for zero values redefined as absolute
        % large range values are dealt with above
        range(1,close_to_zero(1,:)) = -tol;
        range(2,close_to_zero(2,:)) = tol;
    end
else
    error('RANGE_ADD_BORDER:invalid_argument',... 
        'input tol must be a numeric value. Actually: %s',...
        evalc('tol'));
end
if ~isempty(range_store)
    range = [range,range_store(:,5:end)];
end

function range = get_relative_range(range_in,tol)
% Add relative-sized border to the range.
%
sig_range = sign(range_in);

% Build unit sized border, with min range equal to 1-tol and max range equal
% to 1+tol used when relative size border is applied.
%
% here we assure that whatever sign the range has, positive
% min_ranges are expanded towards zero and negative min_ranges
% -- towards minus infinity. Max ranges behave just opposite, i.e.
% positive max_ranges -- towards plus infinity and negative --
% towards zero.
min_border = 1-tol*sig_range(1,:);
max_border = 1+tol*sig_range(2,:);
border = [min_border;max_border];
% Calculate relative sized range border itself
range = range_in.*border;
