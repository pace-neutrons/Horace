function y=f0erfc(x)
% Calculates  exp(x^2)*erfc(x) to relative accuracy of better than
% 3d-15 over the range 0 =< x =< infinity.
%
% Method:
%       0 =< x =< 12   Tchebyshev polynomial approximation
%      13 =< x =< inf  assymptotic expansion
%       intermediate   interpolation of the two
%
% Author: T.G.Perring 10/3/93 - translated to matlab TGP Jan 2013

ilo=(x>=0)&(x<12);
ihi=(x>13);
imix=(x>=12)&(x<=13);

y=zeros(size(x));

if any(ilo(:))
    y(ilo)=f0chb(x(ilo));
end

if any(ihi(:))
    y(ihi)=f0ass(x(ihi));
end

if any(imix(:))
    y(imix)=(x(imix)-12).*f0ass(x(imix)) - (x(imix)-13).*f0chb(x(imix));
end

%------------------------------------------------------------------------
function y=f0chb(x)
%  Tchebyshev polynimial approximation to exp(x^2)*erfc(x)
%  T.G.Perring 10/3/93 - translated to matlab TGP Jan 2013

c=[0.6101430819232002d0, -0.4348412727125773d0,...
    0.1763511936436054d0,   -6.0710795609249290d-02,...
    1.7712068995693948d-02, -4.3211193855671498d-03,...
    8.5421667688699187d-04, -1.2715509060899188d-04,...
    1.1248167243526619d-05,  3.1306388555196740d-07,...
    -2.7098806867464908d-07,  3.0737622856435998d-08,...
    2.5156202393405991d-09, -1.0289297397436670d-09,...
    2.9943894030992624d-11,  2.6051945045679759d-11,...
    -2.6349566972783123d-12, -6.4328598003982052d-13,...
    1.1231626739771627d-13,  1.7390533457728452d-14,...
    -4.3881565048309313d-15, -4.1300296516055823d-16];

d=zeros(size(x)); dd=zeros(size(x)); y=(x-3.75d0)./(x+3.75d0); y2=2*y;
for j=22:-1:2
    sv=d;
    d=y2.*d-dd+c(j);
    dd=sv;
end
y=(y.*d-dd)+0.5*c(1);

%------------------------------------------------------------------------
function y=f0ass(x)
% Assymptotic approximation to exp(x^2)*erfc(x)
% T.G.Perring 10/3/93 - translated to matlab TGP Jan 2013

xfac=0.5./(x.^2);
term=1;
sum=1;
for m=1:10
    term=-term.*((2*m-1)*xfac);
    if all(term(:))==0, break, end
    sum=sum+term;
end
y = (0.564189583547756*sum)./x;
