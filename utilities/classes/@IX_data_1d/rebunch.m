function wout = rebunch(win,varargin)
% Rebunch data points in IX_dataset_1d or array of IX_dataset_1d into groups of n
%
% Histogram data:
%   >> wout = rebunch(win, nbin)        % rebunches the data in groups of nbin
%
% Point data:
%   >> wout = rebunch(win, nbin)        % rebunching: point averaging (default)
%   >> wout = rebunch(win, nbin, 'int') % rebunching: trapezoidal integration
%
%   The argument 'int' is ignored by any histogram datasets.
%
% Note:
%   >> wout = rebunch(win)              % same as nbin=1 i.e. wout is just a copy of win
%
% Note that this function correctly accounts for x_distribution if histogram data.
% Point data is averaged, as it is assumed point data is sampling a function.

% T.G.Perring 21 May 2011 Based on the original mgenie rebunch routine, but with
%                         extension to non-distribution histogram datasets, added
%                         trapezoidal integration for point data, and catch case of one data point

small = 1.0e-10;

% Check input arguments
% ---------------------
% Check binning
if nargin>=2
    nbin=varargin{1};
    if ~isnumeric(nbin) || ~isscalar(nbin) || ~abs(nbin-round(nbin))<small || round(nbin)<1
        error ('Check second argument is a whole number greater or equal to unity')
    end
    nbin = round(nbin);
elseif nargin==1
    nbin=1;
else
    error ('Check number of input arguments')
end

% Check averging type
if nargin==3
    if ischar(varargin{2}) && strcmpi(varargin{2},'int')
        point_ave=false;
    else
        error('Check arguments')
    end
else
    point_ave=true;
end

% Catch trivial case of nbin=1
if nbin==1
    wout=win;
    return
end

% Perform rebunching
if numel(win)==1
    wout=single_rebunch(win,nbin,point_ave);
else
    wout=repmat(IX_dataset_1d,size(win));
    for i=1:numel(win)
        wout(i)=single_rebunch(win(i),nbin,point_ave);
    end
end


%==================================================================================================
function wout = single_rebunch(win,nbin,point_ave)
% Rebunch data. Assumes already checked that nbin>=2. Point_ave only used for point data

% Catch case of only one data point - nothing to do
if length(win.x)==1
    wout=win;
    return
end

ny=length(win.signal);
nx=length(win.x);

my_total=floor((ny-1)/nbin) + 1;    % total number of bins in rebunched array
my_whole=floor(ny/nbin);            % number of rebunched bins with NBIN points contributing from original array

%---------------------------------------------------------------------------------------------    
% Histogram data
if nx~=ny
    % Get arrays of total counts and errors
    if win.x_distribution
        xin_bins=diff(win.x);
        ytemp=win.signal'.*xin_bins;
        etemp=win.error'.*xin_bins;
    else
        ytemp=win.signal';
        etemp=win.error';
    end

    % Sum for each new bunch
    xout=[win.x(1:nbin:nx-1),win.x(nx)];
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

    % Convert back to distribution, if necessary
    if win.x_distribution
        yout=yout./xout_bins;
        eout=eout./xout_bins;
    end
    
%---------------------------------------------------------------------------------------------    
% Point data
else
    if point_ave
        % Point averaging
        xout=zeros(1,my_total);
        yout=zeros(1,my_total);
        eout=zeros(1,my_total);
        if (my_total-my_whole ~=0) % 1 or more leftover values at end of array
            xout(my_total)=sum(win.x(my_whole*nbin+1:ny))/(ny-my_whole*nbin);
            yout(my_total)=sum(win.signal(my_whole*nbin+1:ny))/(ny-my_whole*nbin);
            eout(my_total)=sqrt(sum(win.error(my_whole*nbin+1:ny).^2))/(ny-my_whole*nbin);
        end
        if (my_whole ~= 0)         % 1 or more completely filled new bins
            xout(1:my_whole)=sum(reshape(win.x(1:my_whole*nbin),nbin,my_whole))/nbin;
            yout(1:my_whole)=sum(reshape(win.signal(1:my_whole*nbin),nbin,my_whole))/nbin;
            eout(1:my_whole)=sqrt(sum(reshape(win.error(1:my_whole*nbin).^2,nbin,my_whole)))/nbin;
        end
    else
        % Trapezoidal integration averaging
        ind=nbin*(1:floor((nx-1)/nbin));
        xbounds=[win.x(1),0.5*(win.x(ind)+win.x(ind+1)),win.x(nx)];     % integration ranges
        xout=0.5*(xbounds(2:end)+xbounds(1:end-1));     % centres of integration ranges
        xout_bins=diff(xbounds);
        [yout,eout] = integrate_1d_points (win.x, win.signal, win.error, xbounds);
        yout=yout./xout_bins;
        eout=eout./xout_bins;

    end
%---------------------------------------------------------------------------------------------    
end

wout = IX_dataset_1d (xout, yout, eout, win.title, win.x_axis, win.s_axis, win.x_distribution);
