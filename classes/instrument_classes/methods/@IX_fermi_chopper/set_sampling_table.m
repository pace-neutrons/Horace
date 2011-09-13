function table=set_sampling_table(fermi,varargin)
% Create lookup table from which to create random sampling of chopper transmission function
%
%   >> a=set_sampling_table(fermi)            % sampling_table, default no. points, in-phase 
%   >> a=set_sampling_table(fermi,phase)      % sampling_table, default no. points, in-phase (true) or 180 degree rotated (false)
%   >> a=set_sampling_table(fermi,npnt)       % sampling table, given number of points (n>=2)
%   >> a=set_sampling_table(fermi,npnt,phase)
%

c_e_to_t=2286.271456507406;         % t(us)=c_e_to_t *distance(m)/sqrt(E(meV))
if nargin==1
    npnt=fermi.ntable;
    phase=fermi.phase;
elseif nargin==2
    if isnumeric(varargin{1})
        npnt=varargin{1};
        phase=fermi.phase;
    else
        npnt=fermi.ntable;
        phase=logical(varargin{1});
    end
elseif nargin==3
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

table=zeros(1,npnt);
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
table(2:npnt-1)=findzero(fermi, area, phase);

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
