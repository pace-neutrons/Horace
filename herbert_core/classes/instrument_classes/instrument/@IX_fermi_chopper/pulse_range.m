function [tlo, thi] = pulse_range (obj, varargin)
% Return lower an upper limits of range of chopper pulse (microseconds)
%
%   >> [tlo, thi] = pulse_range (obj)
%   >> [tlo, thi] = pulse_range (obj, phase)     % for specified phase
%   >> [tlo, thi] = pulse_range (obj, ei)        % for an array of specified ei
%   >> [tlo, thi] = pulse_range (obj, ei, phase) % for specified ei and phase
%
% Input:
% -------
%   obj     IX_fermi_chopper object (scalar)
%
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, uses the ei value in the IX_fermi_chopper object
%
%   phase   If true, optimally phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   tlo     Opening time of chopper (microseconds)
%           The time at which there starts to be tranmission. If there is
%           no transmission then is set to zero.
%
%   thi     Closing time of chopper (microseconds)
%           The time at which there ceases to be tranmission. If there is
%           no transmission then is set to zero.


% Check inputs
if ~isscalar(obj)
    error('IX_fermi_chopper:pulse_range:invalid_argument',...
        'Method only takes a scalar object')
end

[ok, mess, ei, phase] = parse_ei_and_phase_ (obj, varargin{:});
if ~ok, error(mess), end

% Calculated transmission relative to optimum for the Fermi chopper frequency
[pk_fwhh, gam] = get_pulse_props_ (obj, ei, phase);

thi = NaN(size(ei));
i1=(gam<1);
thi(i1)= (10^6*pk_fwhh);
i2=(gam>=1&gam<4);
rtgam=sqrt(gam(i2));
thi(i2)=(10^6*pk_fwhh)*(rtgam.*(2-rtgam));

tlo=-thi;

end
