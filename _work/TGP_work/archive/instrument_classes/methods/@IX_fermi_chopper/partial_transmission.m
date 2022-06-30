function f=partial_transmission(fermi,varargin)
% Calculate partial transmission integrated over [-Inf,t] using ei in Fermi chopper object
%
%   >> f=partial_transmission(fermi)            % full transmission (integral over -Inf to +Inf) with phase in fermi
%   >> f=partial_transmission(fermi,phase)      % for specified phase: in-phase (true) or pi-rotated (false)
%   >> f=partial_transmission(fermi,t)          % partial transmission for an array of times with phase in fermi
%   >> f=partial_transmission(fermi,t,phase)    % partial transmission for an array of times with the specified phase
%
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%   t       time (microseconds) (array or scalar)
%           If omitted, use t=Inf
%   phase   if true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   f       Partial transmission. If t=Inf, f = transmission(fermi[,phase])
%           Note that transmission(fermi[,phase]) is only unity at the energy
%          and phase corresponding to peak transmission.


if ~isscalar(fermi), error('Function only takes a scalar object'), end

c_e_to_t=2286.271456507406;         % t(us)=c_e_to_t *distance(m)/sqrt(E(meV))
if nargin==1
    t=Inf;
    phase=fermi.phase;
elseif nargin==2
    if isnumeric(varargin{1})
        t=1e-6*varargin{1};     % get time in seconds
        phase=fermi.phase;
    else
        t=Inf;
        phase=logical(varargin{1});
    end
elseif nargin==3
    t=1e-6*varargin{1};
    phase=logical(varargin{2});
else
    error('Check number of input arguments')
end

vi=1e6*sqrt(fermi.energy)/c_e_to_t;           % incident velocity (m/s)

omega=2*pi*fermi.frequency;
s=2*omega*fermi.curvature;
pk_fwhh=fermi.slit_width/(2*fermi.radius*omega);
if phase
    gam=(2*fermi.radius/pk_fwhh)*abs(1/s-1./vi);
else
    gam=(2*fermi.radius/pk_fwhh)*abs(1/s+1./vi);
end

f=zeros(size(t));
pos_t=t>0;      % negative times
tau=abs(t)/pk_fwhh;
if gam<1
    ilo=tau<gam;
    f(ilo)=0.5*(1-tau(ilo)).^2-((gam-tau(ilo)).^3)/(12*gam);
    ihi=tau>=gam & tau<1;
    f(ihi)=0.5*(1-tau(ihi)).^2;
    f(pos_t)=1-(gam^2)/6 - f(pos_t);
elseif gam<4
    rtgam=sqrt(gam);
    iok=tau<rtgam*(2-rtgam);
    eta=rtgam*(2-rtgam)-tau(iok);
    f(iok)=(eta.^2).*(6*rtgam-eta)/(12*gam);
    f(pos_t)=rtgam*((rtgam-2)^2)*(rtgam+4)/6 - f(pos_t);
end
