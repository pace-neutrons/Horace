function gam=gamma(fermi,varargin)
% Calculate the reduced quantity gamma for a Fermi chopper (abs(gamma)<4 for transmission)
%
%   >> gam=gamma(fermi)           % gamma for ei in Fermi chopper object
%   >> gam=gamma(fermi,phase)     % for in-phase (default) or 180 degree rotated phase
%   >> gam=gamma(fermi,ei)        % for an array of other ei
%   >> gam=gamma(fermi,ei,phase)
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, use the ei value in the IX_fermi_chopper object
%   phase   if true, correctly phased; if false, 180 degrees out of phase
%           If omitted, then assume true
%
% Output:
% -------
%   gam     (2*R/peak_fwhh)*abs(1/s-1/v);   s=optimal transmission

c_e_to_t=2286.271456507406;         % t(us)=c_e_to_t *distance(m)/sqrt(E(meV))
if nargin==1
    ei=fermi.energy;
    phase=fermi.phase;
elseif nargin==2
    if isnumeric(varargin{1})
        ei=varargin{1};
        phase=fermi.phase;
    else
        ei=fermi.energy;
        phase=logical(varargin{1});
    end
elseif nargin==3
    ei=varargin{1};
    phase=logical(varargin{2});
end

vi=1e6*sqrt(ei)/c_e_to_t;           % incident velocity (m/s)

omega=2*pi*fermi.frequency;
s=2*omega*fermi.curvature;
pk_fwhh=fermi.slit_width/(2*fermi.radius*omega);
if phase
    gam=(2*fermi.radius/pk_fwhh)*abs(1/s-1./vi);
else
    gam=(2*fermi.radius/pk_fwhh)*abs(1/s+1./vi);
end
