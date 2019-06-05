function table=sampling_table(fermi,varargin)
% Create lookup table from which to create random sampling of chopper transmission function
%
%   >> a=sampling_table(fermi)              % sampling_table for ei and phase in Fermi chopper object
%   >> a=sampling_table(fermi,phase)        % for specified phase: in-phase (true) or pi-rotated (false)
%   >> a=sampling_table(fermi,npnt)         % table has specified number of points (npnt>=2)
%   >> a=sampling_table(fermi,npnt,phase)   % specified number of points and phase
%   >> a=sampling_table(...,'fast')         % fast but less accurate algorithm
%
% Input:
% -------
%   fermi   IX_fermi_chopper object
%   npnt    [Optional] Number of points in lookup table
%           If omitted, then set to 100
%   phase   [Optional] If true, correctly phased; if false, 180 degrees out of phase
%           If omitted, uses phase in the IX_fermi_chopper object
%   opt     [Optional] if 'fast', use faster but less accurate algorithm
%           The 'fast' algorithm is good to about dt/tmax = 1e-5
%           For table length  50:  c.  250x faster
%                            100:  c.  500x faster
%                           1000:  c. 4000x faster
%
% Output:
% -------
%   a       Look-up table to convert a random number from uniform distribution
%          in the range 0 to 1 into a time deviation in microseconds (column vector)

npnt_default=100;

if ~isscalar(fermi), error('Function only takes a scalar object'), end

c_e_to_t=2286.271456507406;         % t(us)=c_e_to_t *distance(m)/sqrt(E(meV))

% Find if 'fast' option is present
if nargin>=2 && is_string(varargin{end})
    if strcmpi(varargin{end},'fast')
        fast=true;
        narg=nargin-1;
    else
        error('Unrecognised optional argument')
    end
else
    fast=false;
    narg=nargin;
end

% Parse other arguments
if narg==1
    npnt=npnt_default;
    phase=fermi.phase;
elseif narg==2
    if isnumeric(varargin{1})
        npnt=varargin{1};
        phase=fermi.phase;
    else
        npnt=npnt_default;
        phase=logical(varargin{1});
    end
elseif narg==3
    npnt=varargin{1};
    phase=logical(varargin{2});
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

if npnt<2, error('Check number of sampling points in the table to be constructed'), end

table=zeros(npnt,1);
% fill end points of table with known time limits (avoid problems in findzero
% Note that if gam>=4, all times in the table will be zero. Probably best default unless fail.
if gam<1
    table(1)  =-1e6*pk_fwhh;
    table(end)= 1e6*pk_fwhh;
elseif gam<4
    rtgam=sqrt(gam);
    table(1)  =-1e6*pk_fwhh*rtgam*(2-rtgam);
    table(end)= 1e6*pk_fwhh*rtgam*(2-rtgam);
end

area_full=partial_transmission(fermi,Inf,phase);     % full transmission
area=(area_full/(npnt-1))*(1:npnt-2);
if ~fast
    table(2:npnt-1)=findzero(fermi, area, phase);
else
    npnt0=max(500,5*npnt);  % for a lookup table of areas to interpolate on
    t=(table(1)*(npnt0-1:-1:0)+table(end)*(0:npnt0-1))/(npnt0-1);
    A=partial_transmission(fermi,t,phase);
    table(2:npnt-1)=interp1(A,t,area,'linear','extrap');
end

end

%----------------------------------------------------------------------
function t = findzero(fermi, a, phase)

options = optimset('Display', 'off'); % Turn off Display
t = zeros(size(a));
for i=1:numel(a)
    aroot = a(i);
    t(i) = fzero(@func, 0, options);
end

    function y = func(x) % Compute the polynomial.
        y = partial_transmission(fermi,x,phase)-aroot;
    end
end
