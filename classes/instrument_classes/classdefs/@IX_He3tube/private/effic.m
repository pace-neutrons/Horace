function val = effic (alf)
% Efficiency of a 3He cylindrical tube
%
%   >> val = effic (alf)
%
% Input:
% ------
%   alf     Inner diameter of 3He tube as a multiple of the macroscopic
%          absoprtion cross-section (scalar or array)
%
% Output:
% -------
%   val     Efficiency (in range 0 to 1) averaged across the width of the
%          tube (same size and shape as alf)
%
%
% History of the algorithm
% ------------------------
%   
%  T.G.Perring June 1990:
%  
%  Algorithm is based on a combination of Taylor series and
%  assymptotic expansion of the double integral for the
%  efficiency, linearly interpolating betweent the two in 
%  region of common accuracy. Checked against numerical
%  integration to yield relative accuracy of 1 part in 10^12
%  or better over the entire domain of the input arguments
%
%  T.G.Perring February 2010:
%  
%  Fortran code minimally adapted for Matlab
%
%  T.G.Perring August 2015:
%
%  Code refactored into a new algorithm that isolates the 
%  calculation of the dimensionless parameter alf


% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)


c_eff_f = [0.7648360390553052,...
    -0.3700950778935237    , 0.1582704090813516,...
    -6.0170218669705407E-02, 2.0465515957968953E-02,...
    -6.2690181465706840E-03, 1.7408667184745830E-03,...
    -4.4101378999425122E-04, 1.0252117967127217E-04,...
    -2.1988904738111659E-05, 4.3729347905629990E-06,...
    -8.0998753944849788E-07, 1.4031240949230472E-07,...
    -2.2815971698619819E-08, 3.4943984983382137E-09,...
    -5.0562696807254781E-10, 6.9315483353094009E-11,...
    -9.0261598195695569E-12, 1.1192324844699897E-12,...
    -1.3204992654891612E-13, 1.4100387524251801E-14,...
    -8.6430862467068437E-16,-1.1129985821867194E-16,...
    -4.5505266221823604E-16, 3.8885561437496108E-16];

c_eff_g = [2.033429926215546,...
    -2.3123407369310212E-02, 7.0671915734894875E-03,...
    -7.5970017538257162E-04, 7.4848652541832373E-05,...
     4.5642679186460588E-05,-2.3097291253000307E-05,...
     1.9697221715275770E-06, 2.4115259271262346E-06,...
    -7.1302220919333692E-07,-2.5124427621592282E-07,...
     1.3246884875139919E-07, 3.4364196805913849E-08,...
    -2.2891359549026546E-08,-6.7281240212491156E-09,...
     3.8292458615085678E-09, 1.6451021034313840E-09,...
    -5.5868962123284405E-10,-4.2052310689211225E-10,...
     4.3217612266666094E-11, 9.9547699528024225E-11,...
     1.2882834243832519E-11,-1.9103066351000564E-11,...
    -7.6805495297094239E-12, 1.8568853399347773E-12];

val=zeros(size(alf));
ilo=(alf<=9);
ihi=(alf>=10);
imix=(alf>9 & alf<10);

if any(ilo(:))
    val(ilo) = (pi/4)*(alf(ilo).*effchb(0,10,c_eff_f,alf(ilo)));
end

if any(ihi(:))
    y = 1-18./alf(ihi);
    val(ihi) = 1 - effchb(-1,1,c_eff_g,y)./(alf(ihi).^2);
end

if any(imix(:))
    eff_f = (pi/4)*(alf(imix).*effchb(0,10,c_eff_f,alf(imix)));
    y = 1-18./alf(imix);
    eff_g = 1 - effchb(-1,1,c_eff_g,y)./(alf(imix).^2);
    val(imix) = (10-alf(imix)).*eff_f  + (alf(imix)-9).*eff_g;
end

%---------------------------------------------------------------------
function y=effchb(a,b,c,x)
% Essentially CHEBEV of "Numerical Recipes"
d=zeros(size(x)); dd=zeros(size(x)); y=(2*x-a-b)/(b-a); y2=2*y;
for j=numel(c):-1:2
    sv=d;
    d=(y2.*d-dd)+c(j);
    dd=sv;
end
y=(y.*d-dd)+0.5*c(1);
