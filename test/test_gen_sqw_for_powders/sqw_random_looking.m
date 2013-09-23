function weight = sqw_random_looking (qh,qk,ql,en,par)
% Apparently random looking sqw. Very crude - will not work in many cases
%
%   >> weight = sqw_random_looking (qh,qk,ql,en,par)
%
% Input:
% ------
%   qh,qk,ql,en Arrays of h,k,l
%   par         Parameters 
%                   par(1)  Minimum S(Q,w)
%                   par(2)  Maximum S(Q,w)
%                   par(3)  A parameter to control apparent randomness
%                          Different values of par|(3) will result in
%                          different output
%
% Output:
% -------
%   weight      S(Q,w) calculation; in range 

fac=2+cos(50000*abs(par(3)));
f1=fac;
f2=fac.^(16/15);
f3=fac.^(pi/3);
f4=fac.^(exp(1)/2.5);
all4=qh+qk*(1+exp(0.1))+ql*(1+exp(0.2))+en*(1+exp(0.3));
weight=par(1)+par(2)*cos((24000*exp(1))*qh*f1 + (26000*exp(2))*(qk*f2/(pi/2)) +...
    (30000*exp(1.5))*(ql*f3/(sqrt(2))) + (40000*exp(pi/2))*(all4*f4/(sqrt(1.8))));
