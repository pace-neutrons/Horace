function y=pulse_shape(fermi,varargin)
% Calculate partial transmission integrated over [-Inf,t] using ei in Fermi chopper object
%
%   >> y=pulse_shape(fermi)
%   >> y=pulse_shape(fermi,phase)       % for specified phase: in-phase (true) or pi-rotated (false)
%   >> y=pulse_shape(fermi,t)           % for an array of times with phase in fermi
%   >> y=pulse_shape(fermi,t,phase)     % for an array of times with the specified phase
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
%   y       Array of values of pulse shape.
%           Normalised so pulse area is transmission(fermi[,phase])
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

y=zeros(size(t));
tau=abs(t)/pk_fwhh;
if gam<1
    ilo=(tau<gam);
    y(ilo)=1-((gam+tau(ilo)).^2)/(4*gam);
    ihi=(tau>=gam & tau<1);
    y(ihi)=1-tau(ihi);
elseif gam<4
    iok=(tau<sqrt(gam)*(2-sqrt(gam)));
    y(iok)=1-((gam+tau(iok)).^2)/(4*gam);
end
% Normalise so integral w.r.t. microseconds is transmission(fermi[,phase])
y=y*(10^-6/pk_fwhh);
