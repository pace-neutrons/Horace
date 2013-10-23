function weight = sqw_rand_like (qh,qk,ql,en,par)
% Apparently random looking sqw. Very crude - will not work in many cases
%
%   >> weight = sqw_random_looking (qh,qk,ql,en,par)
%
% Input:
% ------
%   qh,qk,ql,en Arrays of h,k,l
%   par         Parameters:
%                   par(1)  Mean S(Q,w)
%                   par(2)  FWHH of S(Q,w)
%
% Output:
% -------
%   weight      S(Q,w) calculation
%               The weight for eah element will lie in the range
%                   par(1)-par(2)/2 to par(1)+par(2)/2

% Get a number in the range 0 to 1 that is very sensitive to the values of qh,qk,ql,en
fac=1+exp(sqrt(0.6374993));
f1=fac^(sqrt(1.109));
f2=fac^(16/15);
f3=fac^(pi/3);
f4=fac^(exp(1)/2.5);
dval=mod(cos(1e5*(fac+sum(f1*qh(:)+f2*qk(:)+f3*ql(:)+f4*en(:)))),1);
val0=rand_like('fetch');        % get current seed
rand_like('start',val0+dval);   % change seed

% Get weight
weight=(par(1)-par(2)/2) + par(2)*rand_like(size(qh));
