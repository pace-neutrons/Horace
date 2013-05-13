function y = ikcarp (x, tauf_in, taus_in, R)
% Calculate normalised Ikeda-Carpenter moderator lineshape.
%
%   >> y = ikcarp (x, tauf, taus, R)
%
% Input:
% ------
%   x       Array of times at which to evaluate the function
%   tauf    Fast decay time (us)
%   taus    Slow decay time (us)
%   R       Weight of storage term (0<=R<=1)
%
% Output:
% -------
%   y       Array of values of the function
%
%
% Assumes |taus| >= |tauf| and 0<=R<=1. Taus and tauf must have the same sign
% (if both are negative then the function is reversed along the time axis)
% 
% Limiting cases of tauf=0, taus=0, R=0 or 1 handled correctly.
% 
% Problems can arise when tauf and/or taus are extremely small but non-zero.

% T.G.Perring 2011-07-20
%   Based on my Fortran 77 code written in c. 1990

c3=1.6666666666666666667d-01; c4=-1.2500000000000000000d-01; c5=5.0000000000000000000d-02;
c6=-1.3888888888888888889d-02; c7=2.9761904761904761905d-03; c8=-5.2083333333333333333d-04;
c9=7.7160493827160493827d-05; c10=-9.9206349206349206349d-06; c11=1.1273448773448773449d-06;
c12=-1.1482216343327454439d-07; c13=1.0598968932302265636d-08;

if sign(taus_in*tauf_in)>=0  % allow one (or both) of tauf=0, taus=0
    tauf=abs(tauf_in); taus=abs(taus_in);
else
    error('tauf and taus must have the same sign')
end

y=zeros(size(x));
pos=(x>=0);
xpos=x(pos);
if tauf~=0
    if taus~=0 && R~=0
        xg = xpos*(1/tauf - 1/taus);
        f_of_xg=zeros(size(xg));
        small_xg=(abs(xg)<0.1);
        if any(small_xg(:))
            xgs=xg(small_xg);
            f_of_xg(small_xg) = (c3+xgs.*(c4+xgs.*(c5+xgs.*(c6+xgs.*(c7+xgs.*(c8+xgs.*(c9+xgs.*(c10+xgs.*(c11+xgs.*(c12+xgs.*c13))))))))));
        end
        if any(~small_xg(:))
            xgb=xg(~small_xg);
            f_of_xg(~small_xg) = (1 - exp(-(xgb)).*(1+(xgb)+0.5*(xgb).^2))./(xgb).^3;
        end
        y(pos) = (((xpos/tauf).^2)/tauf) .* ( 0.5*(1-R)*exp(-(xpos/tauf)) + R*(xpos/taus).*(exp(-(xpos/taus)).*f_of_xg) );
    else
        y(pos) = 0.5*((xpos/tauf).^2).*exp(-(xpos/tauf))/tauf;
    end
else
    if taus~=0 && R==1
        y(pos) = exp(-xpos/taus)/taus;
    else
        if taus~=0 && R~=0
            y(pos)=R*exp(-xpos/taus)/taus;
        end
        y(x==0) = Inf;  % there is at least some component of delta function; do after the evaluation of slowing term to ensure y=Inf at x=0
    end
end
