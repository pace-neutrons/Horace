function wout=hist2point(win,iax)
% Convert histogram axes in IX_dataset_3d (or an array of them) to point axes.
%
%   >> wout=hist2point(win)         % convert both x and y axes
%   >> wout=hist2point(win,iax)     % iax=1, 2 or [1,2] for x, y, and both x and y axes
%
% Leaves point axes unchanged.
%
% Histogram datasets are converted to distribution as follows:
%       Histogram distribution => Point data distribution;
%                                 Signal numerically unchanged
%
%             non-distribution => Point data distribution;
%                                 Signal converted to signal per unit axis length
%
% Histogram data is always converted to a distribution: it is assumed that point
% data represents the sampling of a function at a series of points, and histogram
% non-distribution data is not consistent with that.

% Check input
nd=3;
if nargin==1
    convert_x=true;
    convert_y=true;
    convert_z=true;
else
    if isnumeric(iax) && isvector(iax)    % is non-empty vector (including non-empty scalar)
        if any(mod(iax,1)~=0)||numel(iax)>nd||numel(unique(iax))~=numel(iax)||...
                any(iax<1)||any(iax>nd)
            error('Check indicies of axes to be converted')
        end
        if any(iax==1), convert_x=true; else convert_x=false; end
        if any(iax==2), convert_y=true; else convert_y=false; end
        if any(iax==3), convert_z=true; else convert_z=false; end
    else
        error('Check axes to convert')
    end
end

% Perform conversion
wout=win;
for iw=1:numel(win)
    [dummy,sz]=dimensions(win(iw));
    if convert_x && numel(win(iw).x)>sz(1)
        if numel(win(iw).x)>1
            wout(iw).x=0.5*(win(iw).x(2:end)+win(iw).x(1:end-1));
        else
            wout(iw).x=[];  % can have a histogram dataset with only one bin boundary and empty signal array
        end
        if ~win(iw).x_distribution
            if numel(win(iw).x)>1           % don't need tconsider case of one bin, as signal is [] anyway.
                dx=diff(win(iw).x);
                wout(iw).signal=win(iw).signal./dx';
            end
            wout(iw).x_distribution=true;   % always convert into distribution
        end
    end
    if convert_y && numel(win(iw).y)>sz(2)
        if numel(win(iw).y)>1
            wout(iw).y=0.5*(win(iw).y(2:end)+win(iw).y(1:end-1));
        else
            wout(iw).y=[];  % can have a histogram dataset with only one bin boundary and empty signal array
        end
        if ~win(iw).y_distribution
            if numel(win(iw).y)>1           % don't need tconsider case of one bin, as signal is [] anyway.
                dy=diff(win(iw).y);
                wout(iw).signal=win(iw).signal./dy';
            end
            wout(iw).y_distribution=true;   % always convert into distribution
        end
    end
    if convert_z && numel(win(iw).z)>sz(3)
        if numel(win(iw).z)>1
            wout(iw).z=0.5*(win(iw).z(2:end)+win(iw).z(1:end-1));
        else
            wout(iw).z=[];  % can have a histogram dataset with only one bin boundary and empty signal array
        end
        if ~win(iw).z_distribution
            if numel(win(iw).z)>1           % don't need tconsider case of one bin, as signal is [] anyway.
                dz=diff(win(iw).z);
                wout(iw).signal=win(iw).signal./dz';
            end
            wout(iw).z_distribution=true;   % always convert into distribution
        end
    end
end
