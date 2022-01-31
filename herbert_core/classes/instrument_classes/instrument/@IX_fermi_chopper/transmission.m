function f = transmission (obj, varargin)
% Calculate transmission of a Fermi chopper (unit transmission at optimum)
%
%   >> f = transmission (obj)
%   >> f = transmission (obj, phase)     % for specified phase
%   >> f = transmission (obj, ei)        % for specified ei array
%   >> f = transmission (obj, ei, phase) % for specified ei array and phase
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
%   f       Relative transmission (unity at the energy of peak transmission
%           for optimum phase i.e. phase==1).
%           For other energies the transmission is a number smaller than unity


% Check inputs
if ~isscalar(obj)
    error('IX_fermi_chopper:transmission:invalid_argument',...
        'Method only takes a scalar object')
end

[ok, mess, ei, phase] = parse_ei_and_phase_ (obj, varargin{:});
if ~ok, error(mess), end

% Calculated transmission relative to optimum for the Fermi chopper frequency
[~, gam] = get_pulse_props_ (obj, ei, phase);

f = zeros(size(ei));

i1 = (gam<1);
f(i1) = (1-gam(i1).^2/6);

i2 = (gam >=1 & gam < 4);
rtgam = sqrt(gam(i2));
f(i2) = rtgam .* ((rtgam-2).^2) .* (rtgam+4) / 6;

end
