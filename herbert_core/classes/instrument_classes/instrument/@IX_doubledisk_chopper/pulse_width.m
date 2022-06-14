function [dt, fwhh] = pulse_width(obj,varargin)
% Calculate st. dev. of chopper pulse width distribution (microseconds)
%
%   >> [dt, fwhh] = pulse_width (obj)
%   >> [dt, fwhh] = pulse_width (obj, ei)
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
%   dt      Standard deviation of pulse width (microseconds)
%
%   fwhh    FWHH (microseconds)


if ~isscalar(obj)
    error('IX_doubledisk_chopper:pulse_width:invalid_argument',...
        'Method only takes a scalar double disk chopper object')
end

[T1,T2] = hat_times(obj);
dt = sqrt((T1^2 + T2^2)/12);
fwhh = T2;

if nargin==2
    dt=dt*ones(size(varargin{1}));
    fwhh=fwhh*ones(size(varargin{1}));
    
elseif nargin>2
    error('IX_doubledisk_chopper:pulse_width:invalid_argument',...
        'Check number of input arguments')
end

end
