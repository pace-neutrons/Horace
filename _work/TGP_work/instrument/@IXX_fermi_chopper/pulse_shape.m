function y = pulse_shape(self, varargin)
% Return the pulse height at an array of times
%
%   >> y = pulse_shape(fermi)
%   >> y = pulse_shape(fermi, phase)    % for specified phase
%   >> y = pulse_shape(fermi, t)        % for an array of times 
%   >> y = pulse_shape(fermi, t, phase) % for specified time(s) and phase
%
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%   t       time (microseconds) (array or scalar)
%           If omitted, default is t=Inf
%   phase   if true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   y       Array of values of pulse shape.
%           Normalised so pulse area is transmission(fermi[,phase])
%           Note that transmission(fermi[,phase]) is only unity at the energy
%          and phase corresponding to peak transmission.


% Check inputs
if ~isscalar(self), error('Function only takes a scalar object'), end

[ok, mess, t, phase] = parse_t_and_phase_ (self, varargin{:});
if ~ok, error(mess), end

% Calculate pulse shape
[pk_fwhh, gam] = get_pulse_props_ (self, self.energy, phase);

y=zeros(size(t));
tau=abs(t)/(10^6*pk_fwhh);
if gam<1
    ilo=(tau<gam);
    y(ilo)=1-((gam+tau(ilo)).^2)/(4*gam);
    ihi=(tau>=gam & tau<1);
    y(ihi)=1-tau(ihi);
elseif gam<4
    iok=(tau<sqrt(gam)*(2-sqrt(gam)));
    y(iok)=1-((gam+tau(iok)).^2)/(4*gam);
end

% Normalise so integral w.r.t. time in microseconds is transmission(fermi[,phase])
y=y*(10^-6/pk_fwhh);
