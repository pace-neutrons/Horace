function f = partial_transmission (obj, varargin)
% Calculate partial transmission - the integral over [-Inf,t]
%
%   >> f = partial_transmission (obj)           % full transmission
%   >> f = partial_transmission (obj, phase)    % for specified phase
%   >> f = partial_transmission (obj, t)        % for times with phase in fermi
%   >> f = partial_transmission (obj, t, phase) % for times with the specified phase
%
%
% Input:
% -------
%   obj     IX_fermi_chopper object (scalar)
%
%   t       Upper limit of integration range [-Inf,t] (microseconds) (array
%           or scalar)
%           If omitted, default is t = Inf
%
%   phase   if true, optimally phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   f       Partial transmission. If t=Inf, f = transmission(obj[,phase])
%           Note that transmission(obj[,phase]) is only unity at the energy
%          and phase corresponding to peak transmission.


% Check inputs
if ~isscalar(obj)
    error('IX_fermi_chopper:partial_transmission:invalid_argument',...
        'Method only takes a scalar object')
end

[ok, mess, t, phase] = parse_t_and_phase_ (obj, varargin{:});
if ~ok, error(mess), end

% Calculated partial transmission relative to optimum for the Fermi chopper frequency
[pk_fwhh, gam] = get_pulse_props_ (obj, obj.energy_, phase);

f = zeros(size(t));
pos_t = (t>0);      % negative times
tau = abs(t) / (10^6*pk_fwhh);
if gam < 1
    ilo = (tau<gam);
    f(ilo) = 0.5 * (1-tau(ilo)).^2 - ((gam-tau(ilo)).^3)/(12*gam);
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

end
