function wout=linspace(win,n)
% Make a datset with the same x range but with a uniform grid of x values
%
%   >> wout = linspace(win,n)
%
%   win     IX_dataset_1d or array of IX_dataset_1d
%   n       Number of points in which to divide the x-axis e.g.
%               >> wout=linspace(win,1000);
%
%   wout    Output IX_datset_1d or array of IX_datset_1d. The signal and
%           error arrays are set to zeros.
%
% Useful e.g. when plotting the result of a fit: often one wants a dataset
% with a fine grid of x-values over the range of the data to create a fine
% plot of the calculated function:
%
%   >> [wfit,fitdata]=multifit(wdata,@gauss_bkgd,[10,7,1,0,0]);
%   >> wtmp = linspace(wdata,1000);
%   >> wcalc = func_eval(wtmp,@gauss_bkgd,fitdata.p);
%   >> acolor blue
%   >> dp(wdata)
%   >> acolor r
%   >> pl(wcalc)

if nargin==1 || isempty(n)
    wout=win;   % do nothing if not given n
    return
elseif ~(isscalar(n) && isnumeric(n) && rem(n,1)==0 && n>0)
    error('Check number of sub-divisions is an integer bigger than zero')
end

wout=win;
status=ishistogram(win);
for i=1:numel(wout)
    if numel(win(i).x)>1
        xtmp=linspace(win.x(1),win.x(end),n);
        stmp=zeros(n-status(i),1);
        etmp=zeros(n-status(i),1);
        wout(i).x=xtmp; wout(i).signal=stmp; wout(i).error=etmp;
    end
end
