function y=f1erfc(x)
% Calculates [1 - 2*x*exp(x^2)*erfc(x)]/sqrt(pi) to better than
% 6d-15 over the range 0 =< x =< infinity.
%
% Method:
%          0 =< x =< 8.0   tchebyshev polynomial expansion
%       8.75 =< x =< inf   assymptotic expansion
%         intermediate     interpolation of the two
%
% Author: T.G.Perring  22/3/93 - translated to matlab TGP Jan 2013

ilo=(x>=0)&(x<8);
ihi=(x>8.75);
imix=(x>=8)&(x<=8.75);

y=zeros(size(x));

if any(ilo(:))
    y(ilo)=f1chb(x(ilo));
end

if any(ihi(:))
    y(ihi)=f1ass(x(ihi));
end

if any(imix(:))
    y(imix)=(4/3)*((x(imix)-8).*f1ass(x(imix)) - (x(imix)-8.75).*f1chb(x(imix)));
end

%------------------------------------------------------------------------------------
function y=f1chb(x)
% Calculates [1 - 2*x*exp(x^2)*erfc(x)]/sqrt(pi) using
% Tchebyshev polynimial approximation to exp(x^2)*erfc(x)
%
% T.G.Perring 22/3/93 - translated to matlab TGP Jan 2013

c=[0.3145472984566613, -0.2374024562735514,...
    0.1152758460474807,     -4.0523783807822534e-02,...
    1.0976288141821601e-02, -2.3188801960474240e-03,...
    3.7381543689457453e-04, -4.2510157502067547e-05,...
    2.5170876472113690e-06,  1.2329716044312544e-07,...
    -3.8279888977532650e-08,  1.6384954287795850e-09,...
    3.5178277513203682e-10, -3.8180766881446005e-11,...
    -3.1991947979648216e-12,  6.0736304874353664e-13,...
    3.6304570460998775e-14, -9.1085472497809406e-15,...
    -6.7057470687359455e-16,  1.9678703111480900e-16 ];

d=zeros(size(x)); dd=zeros(size(x)); y=(1.3*x-2.625)./(0.7*x+2.625); y2=2*y;
for j=20:-1:2
    sv=d;
    d=y2.*d-dd+c(j);
    dd=sv;
end
y=(y.*d-dd)+0.5*c(1);

%------------------------------------------------------------------------------------
function y=f1ass(x)
% Calculates [1 - 2*x*exp(x^2)*erfc(x)]/sqrt(pi) using
% assymptotic approximation
%
% T.G.Perring 22/3/93 - translated to matlab TGP Jan 2013

xfac=0.5./(x.^2);
term=1;
sum=1;
for m=1:15
    term=-term.*((2*m+1)*xfac);
    if all(term(:))==0, break, end
    sum=sum+term;
end
y = (0.564189583547756*sum).*xfac;
