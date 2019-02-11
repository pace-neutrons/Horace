function [dt, pk_fwhh, fwhh] = pulse_width(self, varargin)
% Calculate st. dev. of chopper pulse width distribution (microseconds)
%
%   >> [dt, pk_fwhh, fwhh] = pulse_width(fermi)
%   >> [dt, pk_fwhh, fwhh] = pulse_width(fermi, phase)     % for specified phase
%   >> [dt, pk_fwhh, fwhh] = pulse_width(fermi, ei)        % for an array of specified ei
%   >> [dt, pk_fwhh, fwhh] = pulse_width(fermi, ei, phase) % for specified ei and phase
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, uses the ei value in the IX_fermi_chopper object
%   phase   if true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   dt      Standard deviation of pulse width (microseconds)
%   pk_fwhh FWHH at energy and phase corresponding to maximum
%           transmission (microseconds)
%   fwhh    FWHH for ei and phase (microseconds)


% Check inputs
if ~isscalar(self), error('Method only takes a scalar object'), end

[ok, mess, ei, phase] = parse_ei_and_phase_ (self, varargin{:});
if ~ok, error(mess), end

% Calculate widths
[pk_fwhh, gam] = get_pulse_props_ (self, ei, phase);

% - Variance
var=zeros(size(ei));
i1=(gam<1);
var(i1)=(pk_fwhh^2/6)*((1-gam(i1).^4/10)./(1-gam(i1).^2/6));
i2=(gam>=1&gam<4);
rtgam=sqrt(gam(i2));
var(i2)=(pk_fwhh^2/6)*(0.6*gam(i2).*((rtgam-2).^2).*(rtgam+8)./(rtgam+4));
dt=1e6*sqrt(var);

% - FWHH of chopper in optimal configuration
pk_fwhh=1e6*pk_fwhh;

% Actual FWHH (note pk_fwhh is in microseconds at this point n the code)
fwhh=zeros(size(ei));
i0=(gam<4/7);
fwhh(i0)=pk_fwhh*(1+gam(i0)/4);
fwhh(~i0)=pk_fwhh*(2*gam(~i0).*(4-gam(~i0)))./...
    (2*gam(~i0) + sqrt(2*gam(~i0).*(4+gam(~i0))));
