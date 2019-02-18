function f = partial_transmission(self,varargin)
% Calculate partial transmission - the integral over [-Inf,t]
%
%   >> f = partial_transmission(fermi)           % full transmission
%   >> f = partial_transmission(fermi, phase)    % for specified phase
%   >> f = partial_transmission(fermi, t)        % for times with phase in fermi
%   >> f = partial_transmission(fermi, t, phase) % for times with the specified phase
%
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%
%   t       time (microseconds) (array or scalar)
%           If omitted, default is t=Inf
%
%   phase   if true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   f       Partial transmission. If t=Inf, f = transmission(fermi[,phase])
%           Note that transmission(fermi[,phase]) is only unity at the energy
%          and phase corresponding to peak transmission.


% Check inputs
if ~isscalar(self), error('Method only takes a scalar Fermi chopper object'), end

[ok, mess, t, phase] = parse_t_and_phase_ (self, varargin{:});
if ~ok, error(mess), end

% Calculated partial transmission relative to optimum for the Fermi chopper frequency
[pk_fwhh, gam] = get_pulse_props_ (self, self.energy_, phase);

f=zeros(size(t));
pos_t=t>0;      % negative times
tau=abs(t)/(10^6*pk_fwhh);
if gam<1
    ilo=(tau<gam);
    f(ilo)=0.5*(1-tau(ilo)).^2-((gam-tau(ilo)).^3)/(12*gam);
    ihi=(tau>=gam & tau<1);
    f(ihi)=0.5*(1-tau(ihi)).^2;
    f(pos_t)=1-(gam^2)/6 - f(pos_t);
elseif gam<4
    rtgam=sqrt(gam);
    iok=(tau<rtgam*(2-rtgam));
    eta=rtgam*(2-rtgam)-tau(iok);
    f(iok)=(eta.^2).*(6*rtgam-eta)/(12*gam);
    f(pos_t)=rtgam*((rtgam-2)^2)*(rtgam+4)/6 - f(pos_t);
end
