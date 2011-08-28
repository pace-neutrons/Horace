function wout=point2hist(win,iax)
% Convert point axes in IX_dataset_2d (or an array of them) to histogram axes.
%
%   >> wout=point2hist(win)         % convert both x and y axes
%   >> wout=point2hist(win,iax)     % iax=1, 2 or [1,2] for x, y, and both x and y axes
%
% Leaves histogram datasets unchanged.

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
            wout(iw).x=bin_boundaries_simple(win(iw).x);
        else
            wout(iw).x=0;   % need to give a single value
        end
    end
    if convert_y && numel(win(iw).y)==sz(2)
        if numel(win(iw).y)>0
            wout(iw).y=bin_boundaries_simple(win(iw).y);
        else
            wout(iw).y=0;   % need to give a single value
        end
    end
end
