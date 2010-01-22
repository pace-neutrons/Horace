function sout=gauss_1d(x,p)
%
% 2d gaussian
%
% p = [Amp cen wid]
%

sout=p(1)*(exp(-0.5*((x-p(2))/p(3)).^2));