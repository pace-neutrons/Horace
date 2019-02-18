function [tlo,thi] = pulse_range (self,varargin)
% Return lower an upper limits of range of double disk chopper (microseconds)
%
%   >> [tlo,thi] = pulse_range (disk)
%   >> [tlo,thi] = pulse_range (disk, ei)
%
% In fact, for a disk chopper the pulse width is trivially independent of the
% energy
%
% Input:
% -------
%   disk    IX_doubledisk_chopper object
%   ei      Incident energy (meV) (array or scalar)
%
% Output:
% -------
%   tlo     Opening time of chopper (microseconds)
%   thi     Closing time of chopper (microseconds)


if ~isscalar(self), error('Method only takes a scalar double disk chopper object'), end

[T1,T2] = hat_times(self);
tlo = -0.5*(T1+T2);
thi = 0.5*(T1+T2);

if nargin==2
    tlo=tlo*ones(size(varargin{1}));
    thi=thi*ones(size(varargin{1}));
elseif nargin>2
    error('Check number of input arguments')
end
