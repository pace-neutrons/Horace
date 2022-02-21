function f = partial_transmission (obj, varargin)
% Calculate partial transmission integrated over [-Inf,t]
%
%   >> f = partial_transmission (obj)    % full transmission (t = +Inf); ==1
%   >> f = partial_transmission (obj, t)
%
%
% Input:
% -------
%   obj     IX_doubledisk_chopper object (scalar)
%
%   t       time (microseconds) (array or scalar)
%           If omitted, use t=Inf
%
% Output:
% -------
%   f       Partial transmission. If t=Inf, f = transmission(disk)
%           Note that transmission(disk) is in fact unity independent of energy


if ~isscalar(obj)
    error('IX_doubledisk_chopper:partial_transmission:invalid_argument',...
        'Method only takes a scalar double disk chopper object')
end

if nargin==1
    f = 1;
    
elseif nargin==2
    t = varargin{1};     % time in microseconds
    [T1, T2] = hat_times (obj);
    f = area_conv_hh (t, T1, T2);
    
else
    error('IX_doubledisk_chopper:partial_transmission:invalid_argument',...
        'Check number of input arguments')

end

end
