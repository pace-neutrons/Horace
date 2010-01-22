function sout=gauss_2d(x,y,p)
%
% 2d gaussian
%
% p = [Amp cen1 cen2 wid1 wid2]
%

sout=p(1)*(exp(-0.5*((x-p(2))/p(4)).^2)).*(exp(-0.5*((y-p(3))/p(5)).^2));