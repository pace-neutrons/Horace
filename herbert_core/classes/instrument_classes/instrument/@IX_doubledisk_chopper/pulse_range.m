function [tlo, thi] = pulse_range (obj, varargin)
% Return lower and upper limits of range of double disk chopper (microseconds)
%
%   >> [tlo, thi] = pulse_range (obj)
%   >> [tlo, thi] = pulse_range (obj, ei)
%
% In fact, for a disk chopper the pulse width is trivially independent of the
% energy
%
% Input:
% -------
%   obj     IX_doubledisk_chopper object (scalar)
%
%   ei      Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   tlo     Opening time of chopper (microseconds)
%
%   thi     Closing time of chopper (microseconds)


if ~isscalar(obj)
    error('IX_doubledisk_chopper:pulse_range:invalid_argument',...
        'Method only takes a scalar double disk chopper object')
end

[T1, T2] = hat_times(obj);
tlo = -(T1+T2) / 2;
thi = (T1+T2) / 2;

if nargin==2
    tlo = tlo * ones(size(varargin{1}));
    thi = thi * ones(size(varargin{1}));
elseif nargin>2
    error('IX_doubledisk_chopper:pulse_range:invalid_argument',...
        'Check number of input arguments')
end

end
