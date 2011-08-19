function wout = integrate (win, varargin)
% Integrate one or more IX_dataset_1d objects between two limits
%
%   >> wout = integrate (win, xmin, xmax)
%   >> wout = integrate (win, [xmin, xmax])
%
%   win         Single or array of IX_dataset_1d datasets to be integrated
%   xmin        Lower integration limit (scalar, or array with number of elements matching win)
%   xmax        Upper integration limit (scalar, or array with number of elements matching win)
%
%   wout        Ouput:
%               - if single input dataset, then structure with two fields
%                   wout.val    integral
%                   wout.err    standard deviation
%               - if array of input dataset
%                   wout        single IX_dataset_1d of integrals
%
% Function uses histogram integration for histogram data, and
% trapezoidal integration for point data.

nw=numel(win);
if nw==0
    wout.val=[]; wout.err=[]; return
end

if nargin==2 && isnumeric(varargin{1}) && numel(varargin{1})==2
    xmin=varargin{1}(1);
    xmax=varargin{1}(2);
elseif nargin==3
    xmin=varargin{1};
    xmax=varargin{2};
else
    error('Check number of input arguments')
end

if isnumeric(xmin)
    if isscalar(xmin)
        xmin=xmin*ones(size(win));
    elseif numel(xmin)~=nw
        error('Lower integration limit must be scalar or array with same number of elements as there are datasets')
    end
else
    error('Lower integration limit must be numeric')
end

if isnumeric(xmax)
    if isscalar(xmax)
        xmax=xmax*ones(size(win));
    elseif numel(xmax)~=nw
        error('Upper integration limit must be scalar or array with same number of elements as there are datasets')
    end
else
    error('Upper integration limit must be numeric')
end

dx=xmax-xmin;
if any(dx<=0)
    error('Lower integration limit(s) must be less than corresponding upper integration limit(s)')
end

val=zeros(1,nw);
err=zeros(1,nw);
nbad=0;
for iw=1:nw
    if numel(win(iw).x)==1, nbad=nbad+1; end    % number of datasets which cannot be integrated
    if numel(win(iw).x)>numel(win(iw).signal)
        % histogram data
        if win(iw).x_distribution
            [val_temp,err_temp] = rebin_1d_hist (win(iw).x, win(iw).signal, win(iw).error, [xmin(iw),xmax(iw)]);
        else
            xbins=diff(win(iw).x');
            ytemp=win(iw).signal./xbins;
            etemp=win(iw).error./xbins;
            [val_temp,err_temp] = rebin_1d_hist (win(iw).x, ytemp, etemp, [xmin(iw),xmax(iw)]);
        end
        val(iw)=val_temp*dx(iw);
        err(iw)=err_temp*dx(iw);
    else
        % point data
        [val(iw),err(iw)] = integrate_1d_points (win(iw).x, win(iw).signal, win(iw).error, [xmin(iw),xmax(iw)]);
    end
end

if nbad>0
    warning([num2str(nbad),' datasets could not be integrated: were empty histogram datasets or point datasets with a single point'])
end

if nw==1
    wout.val=val;
    wout.err=err;
else
    x_axis=IX_axis('Dataset index');
    if all(xmin==xmin(1)) && all(xmax==xmax(1))
        s_axis=IX_axis(['Integral between ',num2str(xmin(1)),' and ',num2str(xmax(1)),' along x-axis']);
    else
        s_axis=IX_axis('Integral along x-axis (range depends on dataset index)');
    end
    wout=IX_dataset_1d(1:nw,val,err,win(1).title,x_axis,s_axis,false);
end
