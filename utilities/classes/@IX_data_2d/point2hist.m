function wout=point2hist(win,iax)
% Convert point axes in IX_dataset_2d (or an array of them) to histogram axes.
%
%   >> wout=point2hist(win)         % convert both x and y axes
%   >> wout=point2hist(win,iax)     % iax=1, 2 or [1,2] for x, y, and both x and y axes
%
% Leaves histogram datasets unchanged.
%
% Point datasets are converted to distributions as follows:
%       Point distribution => Histogram distribution;
%                             Signal numerically unchanged
%
%         non-distribution => Histogram distribution;
%                             Signal numerically unchanged
%                     *** Signal caption will be plotted incorrectly if units
%                         are given in the axis description of the point data
%
% Point data is always converted to a distribution: it is assumed that point
% data represents the sampling of a function at a series of points, and only
% a histogram as a distribution is consistent with that.

% Check input
nd=2;
if nargin==1
    convert_x=true;
    convert_y=true;
else
    if isnumeric(iax) && isvector(iax)    % is non-empty vector (including non-empty scalar)
        if any(mod(iax,1)~=0)||numel(iax)>nd||numel(unique(iax))~=numel(iax)||...
                any(iax<1)||any(iax>nd)
            error('Check indicies of axes to be converted')
        end
        if any(iax==1), convert_x=true; else convert_x=false; end
        if any(iax==2), convert_y=true; else convert_y=false; end
    else
        error('Check axes to convert')
    end
end

% Perform conversion
wout=win;
for iw=1:numel(win)
    [dummy,sz]=dimensions(win(iw));
    if convert_x && numel(win(iw).x)==sz(1)
        if numel(win(iw).x)>0
            [wout(iw).x,ok,mess]=bin_boundaries_simple(win(iw).x);
            if ~ok, error(['Cannot convert to histograms along x-axis: ',mess]), end
        else
            wout(iw).x=0;   % need to give a single value
        end
        if ~win(iw).x_distribution, wout(iw).x_distribution=true; end   % always convert into distribution
    end
    if convert_y && numel(win(iw).y)==sz(2)
        if numel(win(iw).y)>0
            [wout(iw).y,ok,mess]=bin_boundaries_simple(win(iw).y);
            if ~ok, error(['Cannot convert to histograms along y-axis: ',mess]), end
        else
            wout(iw).y=0;   % need to give a single value
        end
        if ~win(iw).y_distribution, wout(iw).y_distribution=true; end   % always convert into distribution
    end
end
