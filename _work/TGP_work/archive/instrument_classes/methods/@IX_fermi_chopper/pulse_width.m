function [dt,pk_fwhh,fwhh]=pulse_width(fermi,varargin)
% Calculate st. dev. of chopper pulse width distribution (microseconds)
%
%   >> [dt,pk_fwhh,fwhh]=pulse_width(fermi)        % pulse width for ei and phase in Fermi chopper object
%   >> [dt,pk_fwhh,fwhh]=pulse_width(fermi,phase)  % for specified phase: in-phase (true) or pi-rotated (false)
%   >> [dt,pk_fwhh,fwhh]=pulse_width(fermi,ei)     % for an array of specified ei with the phase in fermi
%   >> [dt,pk_fwhh,fwhh]=pulse_width(fermi,ei,phase) % for specified ei and phase
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%   ei      Incident energy (meV) (array or scalar)
%           If omitted or empty, use the ei value in the IX_fermi_chopper object
%   phase   if true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%
% Output:
% -------
%   dt      Standard deviation of pulse width (microseconds)
%   pk_fwhh FWHH at energy and phase corresponding to maximum
%           transmission (microseconds)
%   fwhh    FWHH (microseconds)

if ~isscalar(fermi), error('Function only takes a scalar object'), end

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
else
    error('Check number of input arguments')
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

% Variance
var=zeros(size(ei));
i1=gam<1;
var(i1)=(pk_fwhh^2/6)*((1-gam(i1).^4/10)./(1-gam(i1).^2/6));
i2=gam>=1&gam<4;
rtgam=sqrt(gam(i2));
var(i2)=(pk_fwhh^2/6)*(0.6*gam(i2).*((rtgam-2).^2).*(rtgam+8)./(rtgam+4));

% FWHH of chopper in optimal configuration
dt=1e6*sqrt(var);
pk_fwhh=1e6*pk_fwhh;

% Actual FWHH
fwhh=zeros(size(ei));
i0=(gam<4/7);
fwhh(i0)=pk_fwhh*(1+gam(i0)/4);
fwhh(~i0)=pk_fwhh*(2*gam(~i0).*(4-gam(~i0)))./...
    (2*gam(~i0) + sqrt(2*gam(~i0).*(4+gam(~i0))));
