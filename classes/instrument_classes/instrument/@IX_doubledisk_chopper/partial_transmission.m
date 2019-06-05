function f = partial_transmission(self,varargin)
% Calculate partial transmission integrated over [-Inf,t]
%
%   >> f = partial_transmission(disk)       % full transmission (integral over -Inf to +Inf); ==1
%                                           % independent of energy (cf. Fermi chopper)
%   >> f = partial_transmission(disk, t)    % partial transmission for an array of times
%
%
% Input:
% -------
%   disk    IX_doubledisk_chopper object
%   t       time (microseconds) (array or scalar)
%           If omitted, use t=Inf
%
% Output:
% -------
%   f       Partial transmission. If t=Inf, f = transmission(disk)
%           Note that transmission(disk) is in fact unity independent of energy


if ~isscalar(self), error('Method only takes a scalar double disk chopper object'), end

if nargin==1
    f=1;
elseif nargin==2
    t=varargin{1};     % time in microseconds
    [T1,T2] = hat_times(self);
    f = area_conv_hh (t, T1, T2);
else
    error('Check number of input argumnets')
end
