function f = transmission(self, varargin)
% Calculate transmission of a Fermi chopper (unit transmission at optimum)
%
%   >> f = transmission(fermi)
%   >> f = transmission(fermi, phase)     % for specified phase
%   >> f = transmission(fermi, ei)        % for an array of specified ei
%   >> f = transmission(fermi, ei, phase) % for specified ei and phase
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, uses the ei value in the IX_fermi_chopper object
%
%   phase   If true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   f       Relative transmission (unity at the energy of peak transmission)
%           For other energies the transmission is a number smaller than unity


% Check inputs
if ~isscalar(self), error('Method only takes a scalar Fermi chopper object'), end

[ok, mess, ei, phase] = parse_ei_and_phase_ (self, varargin{:});
if ~ok, error(mess), end

% Calculated transmission relative to optimum for the Fermi chopper frequency
[~, gam] = get_pulse_props_ (self, ei, phase);

f=zeros(size(ei));
i1=(gam<1);
f(i1)=(1-gam(i1).^2/6);
i2=(gam>=1&gam<4);
rtgam=sqrt(gam(i2));
f(i2)=rtgam.*((rtgam-2).^2).*(rtgam+4)/6;
