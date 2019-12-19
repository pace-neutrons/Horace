function wout = pop (win, T)
% Multiply data set by (hbar.w/kB.T)/(1-exp(-hbar.w/kB.T)))
%
%   >> wout = pop (win, T)      % T = temperature in Kelvin
%
% To invert, i.e. divide by (hbar.w/kB.T)/(1-exp(-hbar.w/kB.T))),
% use negative T
%
% NOTE: This is *NOT* a correction for the Bose factor

tmp = sqw_eval (win, @pop_internal, T);
wout = tmp * win;

%----------------------------------
function y = pop_internal (h,k,l,en,T)
kB=8.6173324e-2;
y = einstein (en/(kB*T));
