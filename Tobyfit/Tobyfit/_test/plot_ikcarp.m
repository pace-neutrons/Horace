function [w,wr]=plot_ikcarp (tauf,taus,R,x,npnt)
% Plot ikccarp function and its components
%
%   >> plot_ikcarp (tauf,taus,R)
%   >> plot_ikcarp (tauf,taus,R,x)
%   >> plot_ikcarp (tauf,taus,R,x,npnt)
%
if ~exist('npnt','var') || isempty(npnt)
    npnt=5000;
end

if ~exist('x','var') || isempty(x)
    x=linspace(0, 3*sqrt(tauf^2+taus^2), npnt);
end

y=ikcarp(x,tauf,taus,R);
yfast=(1-R)*ikcarp(x,tauf,0,0);
yslow=y-yfast;

w(1)=IX_dataset_1d(x,yfast);
w(2)=IX_dataset_1d(x,yslow);
w(3)=IX_dataset_1d(x,y);

acolor r b k
dl(w)

% Plot equal spaced t_red
nred=500;
t_red=linspace(0,1,nred);
t_red=t_red(1:end-1);   % knock off the last point
t_av=3*tauf+R*taus;
t_m = (t_red./(1-t_red))*t_av;
yr=ikcarp(t_m,tauf,taus,R);
wr=IX_dataset_1d(t_m,yr);
acolor m
pl(wr)
lx(0,max(x))
