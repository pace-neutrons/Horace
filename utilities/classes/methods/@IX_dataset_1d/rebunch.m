function wout = rebunch(win,varargin)
% Rebunch data points into groups of n
%
%   >> wout = rebunch(win, nbin)   % rebunches the data in groups of nbin
%   >> wout = rebunch(win)         % same as nbin=1 i.e. wout is just a copy of win
%
% Note that this treats histogram data as if it were a distribution, and averages point data
% This is really only used for rebinning when plotting, and this is teh relevant thing to do.

small = 1.0e-10;

% Check input arguments
if nargin==2
    nbin=varargin{1};
    if ~isnumeric(nbin) || ~isscalar(nbin) || ~abs(nbin-round(nbin))<small || nbin<0.5
        error ('Check second argument is a whole number greater or equal to unity')
    end
    nbin = round(nbin);
elseif nargin==1
    nbin=1;
else
    error ('Check number of input arguments')
end

% Catch trivial case of nbin=1
if nbin==1
    wout=win;
    return
end

% non-trivial rebunching (note that the following algorithm does not work if NBIN=1 - fails in SUM)
% -------------------------------------------------------------------------------------------------
ny=length(win.signal);
nx=length(win.x);

my_total=floor((ny-1)/nbin) + 1;    % total number of bins in rebunched array
my_whole=floor(ny/nbin);            % number of rebunched bins with NBIN bins contributing from original array

%---------------------------------------------------------------------------------------------    
if nx~=ny   % histogram data
    xin_bins=win.x(2:ny+1)-win.x(1:ny);
    ytemp=win.y.*xin_bins;
    etemp=win.e.*xin_bins;

    xout=[win.x(1:nbin:nx-1)',win.x(nx)];
    xout_bins=xout(2:my_total+1)-xout(1:my_total);
    yout=zeros(1,my_total);
    eout=zeros(1,my_total);
    if (my_total-my_whole ~=0) % 1 or more leftover values at end of array
        yout(my_total)=sum(ytemp(my_whole*nbin+1:ny));
        eout(my_total)=sqrt(sum(etemp(my_whole*nbin+1:ny).^2));
    end
    if (my_whole ~= 0)         % 1 or more completely filled new bins
        yout(1:my_whole)=sum(reshape(ytemp(1:my_whole*nbin),nbin,my_whole));
        eout(1:my_whole)=sqrt(sum(reshape(etemp(1:my_whole*nbin).^2,nbin,my_whole)));
    end
    yout=yout./xout_bins;
    eout=eout./xout_bins;
%---------------------------------------------------------------------------------------------    
else        % point data
    xout=zeros(1,my_total);
    yout=zeros(1,my_total);
    eout=zeros(1,my_total);
    if (my_total-my_whole ~=0) % 1 or more leftover values at end of array
        xout(my_total)=sum(win.x(my_whole*nbin+1:ny))/(ny-my_whole*nbin);
        yout(my_total)=sum(win.y(my_whole*nbin+1:ny))/(ny-my_whole*nbin);
        eout(my_total)=sqrt(sum(win.e(my_whole*nbin+1:ny).^2))/(ny-my_whole*nbin);
    end
    if (my_whole ~= 0)         % 1 or more completely filled new bins
        xout(1:my_whole)=sum(reshape(win.x(1:my_whole*nbin),nbin,my_whole))/nbin;
        yout(1:my_whole)=sum(reshape(win.y(1:my_whole*nbin),nbin,my_whole))/nbin;
        eout(1:my_whole)=sqrt(sum(reshape(win.e(1:my_whole*nbin).^2,nbin,my_whole)))/nbin;
    end
%---------------------------------------------------------------------------------------------    
end

wout=spectrum(xout,yout,eout, win.title, win.xlab, win.ylab, win.xunit, win.distribution);
