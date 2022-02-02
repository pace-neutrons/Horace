function [dt, pk_fwhh, fwhh] = pulse_width (obj, varargin)
% Calculate widths of chopper pulse (microseconds)
%
%   >> [dt, pk_fwhh, fwhh] = pulse_width (obj)
%   >> [dt, pk_fwhh, fwhh] = pulse_width (obj, phase)     % for specified phase
%   >> [dt, pk_fwhh, fwhh] = pulse_width (obj, ei)        % for specified ei array
%   >> [dt, pk_fwhh, fwhh] = pulse_width (obj, ei, phase) % for specified ei array and phase
%
% Input:
% -------
%   obj     IX_fermi_chopper object (scalar)
%
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, uses the ei value in the IX_fermi_chopper
%           object
%
%   phase   if true, optimally phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   dt      Standard deviation of pulse width (microseconds) (array or scalar)
%
%   pk_fwhh FWHH at energy and phase corresponding to maximum
%           transmission (microseconds) (scalar)
%
%   fwhh    FWHH for ei and phase (microseconds) (array or scalar)
%
% The output arguments take the value zero if there is no transmission


% Check inputs
% ------------
if ~isscalar(obj)
    error('IX_fermi_chopper:pulse_width:invalid_argument',...
        'Method only takes a scalar object')
end

[ok, mess, ei, phase] = parse_ei_and_phase_ (obj, varargin{:});
if ~ok, error(mess), end


% Calculate widths
% ----------------
[pk_fwhh, gam] = get_pulse_props_ (obj, ei, phase);

% - Variance
var = NaN(size(ei));

i1 = (gam<1);
var(i1) = (pk_fwhh^2/6) * ((1-gam(i1).^4 / 10) ./ (1-gam(i1).^2 / 6));

i2 = (gam>=1&gam<4);
rtgam = sqrt(gam(i2));
var(i2) = (pk_fwhh^2/6) * (0.6*gam(i2) .* ...
    ((rtgam-2).^2) .* (rtgam+8) ./ (rtgam+4));
dt=1e6*sqrt(var);       % convert to microseconds

% - FWHH of chopper in optimal configuration
pk_fwhh = 1e6 * pk_fwhh;    % convert to microseconds

% - Actual FWHH (note pk_fwhh is in microseconds at this point in the code)
fwhh = NaN(size(ei));
ilo = (gam<4/7);
fwhh(ilo) = pk_fwhh * (1+gam(ilo)/4);
imed = (~ilo & gam<4);
fwhh(imed) = pk_fwhh * (2*gam(imed) .* (4-gam(imed))) ./ ...
    (2*gam(imed) + sqrt(2*gam(imed).*(4+gam(imed))));

end
