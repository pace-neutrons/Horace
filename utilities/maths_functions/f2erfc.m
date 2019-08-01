function y=f2erfc (x)
% Calculates 0.25*[ (2*x^2+1)*exp(x^2)*erfc(x) - (2/sqrt(pi))*z ] to better than
% 4d-14 over the range 0 =< x =< infinity.
%
% Method:
%          0 =< x =< 6.45  tchebyshev polynomial expansion
%       6.95 =< x =< inf   assymptotic expansion
%       intermediate   interpolation of the two
%
% Author: T.G.Perring  15/3/93 - translated to matlab TGP Jan 2013

ilo=(x>=0)&(x<6.45);
ihi=(x>6.95);
imix=(x>=6.45)&(x<=6.95);

y=zeros(size(x));

if any(ilo(:))
    y(ilo)=f2chb(x(ilo));
end

if any(ihi(:))
    y(ihi)=f2ass(x(ihi));
end

if any(imix(:))
    y(imix)=2*((x(imix)-6.45).*f2ass(x(imix)) - (x(imix)-6.95).*f2chb(x(imix)));
end

%------------------------------------------------------------------------------------
function y=f2chb(x)
% Calculates 0.25*[ (2*x^2+1)*exp(x^2)*erfc(x) - (2/sqrt(pi))*z ] using
% Tchebyshev polynimial approximation to exp(x^2)*erfc(x)
%
% Author: T.G.Perring 15/3/93 - translated to matlab TGP Jan 2013

c=[0.4982624923218042d0,...
    -0.4028410724488546d0,   0.2231526375371779d0,...
    -8.9823450764541962d-02, 2.7353313981800987d-02,...
    -6.4025637443547162d-03, 1.1389270970491133d-03,...
    -1.4579082042654679d-04, 1.1126380423422955d-05,...
    1.2701370948331458d-08,-1.0864157824475029d-07,...
    8.3653826332685811d-09, 6.5166833318475171d-10,...
    -1.2594342513327916d-10,-3.2355285117802169d-12,...
    1.6183560047622336d-12, 1.9830803665854546d-14,...
    -2.1107005032661163d-14,-5.3401727484470029d-16,...
    3.9357406222961799d-16,-1.1379786002407854d-16,...
    1.2656542480726784d-16];

d=zeros(size(x)); dd=zeros(size(x)); y=(2.7*x-4.875)./(1.3*x+4.875); y2=2*y;
for j=22:-1:2
    sv=d;
    d=y2.*d-dd+c(j);
    dd=sv;
end
y=0.25*((y.*d-dd)+0.5*c(1));

%------------------------------------------------------------------------------------
function y=f2ass(x)
% Calculates 0.25*[ (2z^z+1)exp(z^2)erfc(z)-2z/rt(pi) ] for positive z
%
% Author: T.G.Perring  15/3/93 - translated to matlab TGP Jan 2013

xfac=0.5./(x.^2);
term=1;
sum=1;
for m=1:30
    term=-term.*(((2*m+1)*(m+1)/m)*xfac);
    if all(term(:))==0, break, end
    sum=sum+term;
end
y=(0.282094791773878*sum).*xfac./x;
