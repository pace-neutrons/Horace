function plot_ikcarp (tauf,taus,R,x,npnt)
% Plot ikccarp function and its components

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

