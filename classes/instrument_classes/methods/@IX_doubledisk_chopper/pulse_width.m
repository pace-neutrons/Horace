function [dt,fwhh]=pulse_width(disk,varargin)
% Calculate st. dev. of chopper pulse width distribution (microseconds)
%
%   >> [dt,fwhh]=pulse_width(disk)
%   >> [dt,fwhh]=pulse_width(disk,ei)
%
% In fact, for a disk chopper the pulse width is trivially indepoendent of the
% energy
%
% Input:
% -------
%   disk    IX_doubledisk_chopper object
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, use the ei value in the IX_fermi_chopper object
%
% Output:
% -------
%   dt      Standard deviation of pulse width (microseconds)
%   fwhh    FWHH (microseconds)

if ~isscalar(disk), error('Function only takes a scalar object'), end

fwhh = 1e6*disk.slot_width/(4*pi*disk.radius*disk.frequency);
dt = fwhh / sqrt(6);   % st dev for a triangle

if nargin==2
    dt=dt*ones(size(varargin{1}));
    fwhh=fwhh*ones(size(varargin{1}));
elseif nargin>2
    error('Check number of input arguments')
end
