function wout = interp (win, varargin)
% Create new IX_dataset_1d by interpolating existing object(s) onto a new x axis
%
%   >> wout = interp (win, x)
%   >> wout = interp (win, wref)    % take x-axis from reference object
%
% In general takes the options of the Matlab intrinsic function to inpterpolate
% in one dimension, interp1:
%   >> wout = interp (...,method)
%   >> wout = interp (...,method,'extrap')
%   >> wout = interp (...,method,extrapval)
%
% Input:
% ------
%   win     Input IX_dataset_1d or array of IX_dataset_1d objects
%   x       New x-axis values. These are interpreted as bin centres or boundaries
%          for each element of win according as the status of the x values for each object.
% OR
%   wref    Reference IX_datset_1d (scalar). Interpolation is only valid if
%          the objects in win are all histogtam or all point, and wref also
%          has the same type (histogram or point) as win.
%
% Optional input:
%   Arguments as for the Matlab intrinsic interp1. Type >> doc interp1 for more
%   information.
%
% Output:
% -------
%   wout    Output IX_dataset_1d or array of IX_dataset_1d objects.
%           Note that error bars are set to zero.

% Original author: T.G.Perring
%
% Note: the distribution or non-distribution nature of the data will not be changed


% Check input data
hist=ishistogram(win);
if all(hist(:)==hist(1))
    hist_data=hist(1);
else
    error('If the input is an array of IX_dataset_1d objects, they must all contain histogram or all point data')
end

% Check new x-axis values
if isnumeric(varargin{1}) && ~isempty(varargin{1}) && isavector(varargin{1}) && all(diff(varargin{1})>0)     % ok even if scalar or empty
    xnew=varargin{1};
elseif isa(varargin{1},'IX_dataset_1d') && isscalar(varargin{1})
    xnew=varargin{1}.x;
    if ~all(diff(xnew)>0)
        error('The x-axis values in the reference IX_dataset_1d must be strictly monotonic increasing')
    elseif ishistogram(varargin{1})~=hist_data
        error('The reference IX_dataset_1d must have the same data type (histogram or point) as the input data')
    end
else
    error('New x-axis values must be a strictly monotonic increasing array, or provided by a scalar IX_dataset_1d object')
end

% Interpolate
if hist_data
    if numel(xnew)>1
        xi=0.5*(xnew(1:end-1)+xnew(2:end));
    else
        error('Number of new x-axis values must be greater or equal to 2 if the input data is histogram data')
    end
else
    if numel(xnew)>0
        xi=xnew;
    else
        error('Number of new x-axis values must be greater or equal to 1 if the input data is point data')
    end
end

% Interpolate data
wout=win;
for iw=1:numel(win)
    if hist_data
        x=0.5*(win(iw).x(1:end-1)+win(iw).x(2:end));
        signalnew=interp1(x,win(iw).signal,xi,varargin{2:end})';
    else
        signalnew=interp1(win(iw).x,win(iw).signal,xi,varargin{2:end})';
    end
    errornew=zeros(size(signalnew));    % don't try to estimate any errors
    wout(iw)=IX_dataset_1d(win(iw).title, signalnew, errornew,...
        win(iw).s_axis, xnew, win(iw).x_axis, win(iw).x_distribution);
end
