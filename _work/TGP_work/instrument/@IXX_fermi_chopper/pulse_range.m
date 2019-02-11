function [tlo, thi] = pulse_range(self, varargin)
% Return lower an upper limits of range of chopper pulse (microseconds)
%
%   >> [tlo, thi] = pulse_range(fermi)
%   >> [tlo, thi] = pulse_range(fermi, phase)     % for specified phase
%   >> [tlo, thi] = pulse_range(fermi, ei)        % for an array of specified ei
%   >> [tlo, thi] = pulse_range(fermi, ei, phase) % for specified ei and phase
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, uses the ei value in the IX_fermi_chopper object
%   phase   If true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   tlo     Opening time of chopper (microseconds)
%   thi     Closing time of chopper (microseconds)


% Check inputs
if ~isscalar(self), error('Method only takes a scalar object'), end

[ok, mess, ei, phase] = parse_ei_and_phase_ (self, varargin{:});
if ~ok, error(mess), end

% Calculated transmission relative to optimum for the Fermi chopper frequency
[pk_fwhh, gam] = get_pulse_props_ (self, ei, phase);

thi = zeros(size(ei));
i1=(gam<1);
thi(i1)= (10^6*pk_fwhh);
i2=(gam>=1&gam<4);
rtgam=sqrt(gam(i2));
thi(i2)=(10^6*pk_fwhh)*(rtgam.*(2-rtgam));

tlo=-thi;
