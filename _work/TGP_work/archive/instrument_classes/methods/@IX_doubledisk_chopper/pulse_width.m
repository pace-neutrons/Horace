function [dt,fwhh]=pulse_width(disk,varargin)
% Calculate st. dev. of chopper pulse width distribution (microseconds)
%
%   >> [dt,fwhh]=pulse_width(disk)
%   >> [dt,fwhh]=pulse_width(disk,ei)
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
%   dt      Standard deviation of pulse width (microseconds)
%   fwhh    FWHH (microseconds)

if ~isscalar(disk), error('Function only takes a scalar object'), end

[T1,T2] = hat_times(disk);
dt = sqrt((T1^2 + T2^2)/12);
fwhh = T2;

if nargin==2
    dt=dt*ones(size(varargin{1}));
    fwhh=fwhh*ones(size(varargin{1}));
elseif nargin>2
    error('Check number of input arguments')
end
