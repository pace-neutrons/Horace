function val = var_d_alf (alf)
% Mean depth of absorption in a 3He cylindrical tube
%
%   >> val = var_d_alf (alf)
%
% Input:
% ------
%   alf     Inner diameter of 3He tube as a multiple of the macroscopic
%          absoprtion cross-section (scalar or array)
%
% Output:
% -------
%   val     Variance of depth of aborption as a fraction of the radius
%          squared (same size and shape as alf)
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
%  T.G.Perring August 2015:
%
%  Fortran code minimally adapted for Matlab


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


c_var_f = [1.226904583058190,...
    -0.3621914072547197,     6.0117947617747081E-02,...
     1.8037337764424607E-02,-1.4439005957980123E-02,...
     3.8147446724517908E-03, 1.3679160269450818E-05,...
    -3.7851338401354573E-04, 1.3568342238781006E-04,...
    -1.3336183765173537E-05,-7.5468390663036011E-06,...
     3.7919580869305580E-06,-6.4560788919254541E-07,...
    -1.0509789897250599E-07, 9.0282233408123247E-08,...
    -2.1598200223849062E-08,-2.6200750125049410E-10,...
     1.8693270043002030E-09,-6.0097600840247623E-10,...
     4.7263196689684150E-11, 3.3052446335446462E-11,...
    -1.4738090470256537E-11, 2.1945176231774610E-12,...
     4.7409048908875206E-13,-3.3502478569147342E-13];

c_var_g = [1.862646413811875,...
     7.5988886169808666E-02,-8.3110620384910993E-03,...
     1.1236935254690805E-03,-1.0549380723194779E-04,...
    -3.8256672783453238E-05, 2.2883355513325654E-05,...
    -2.4595515448511130E-06,-2.2063956882489855E-06,...
     7.2331970290773207E-07, 2.2080170614557915E-07,...
    -1.2957057474505262E-07,-2.9737380539129887E-08,...
     2.2171316129693253E-08, 5.9127004825576534E-09,...
    -3.7179338302495424E-09,-1.4794271269158443E-09,...
     5.5412448241032308E-10, 3.8726354734119894E-10,...
    -4.6562413924533530E-11,-9.2734525614091013E-11,...
    -1.1246343578630302E-11, 1.6909724176450425E-11,...
     5.6146245985821963E-12,-2.7408274955176282E-12];

g0=(32-3*(pi^2))/48;
g1=14/3-(pi^2)/8;
 
val=zeros(size(alf));
ilo=(alf<=9);
ihi=(alf>=10);
imix=(alf>9 & alf<10);

if any(ilo(:))
    val(ilo) = 0.25*effchb(0,10,c_var_f,alf(ilo));
end

if any(ihi(:))
    y = 1-18./alf(ihi);
    val(ihi) = g0 + g1*effchb(-1,1,c_var_g,y)./(alf(ihi).^2);
end

if any(imix(:))
    var_f = 0.25*effchb(0,10,c_var_f,alf(imix));
    y = 1-18./alf(imix);
    var_g = g0 + g1*effchb(-1,1,c_var_g,y)./(alf(imix).^2);
    val(imix) = (10-alf(imix)).*var_f  + (alf(imix)-9).*var_g;
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

