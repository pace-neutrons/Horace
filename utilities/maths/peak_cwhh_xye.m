function [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh_xye(x,y,e,fac,outer)
% Find centre of half height of the main peak in x-y-e data
%
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh_xye(x,y,e,fac)
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh_xye(x,y,e,fac,outer)
%
% Input data where the y or e are infinite or NaN are eliminated before the peak search
%
% Input:
% ------
%   x       x values
%   y       signal
%   e       standard deviations on signal
%   fac     Factor of peak height at which to determine the centre-height position
%           (default=0.5 i.e. centre-fwhh)
% Peak width option:
%   outer   If false, use positions of nearest points to the peak position that lie
%                    below the factor fac of the peak height to determine the peak width
%                    [Default]
%           if true,  use the most distant points from the peak position
%                    This latter option is only useful if there known to be a single
%                    peak in the data.
%   
% Output:
% -------
%   xcent   Centre of factor-of-height
%   xpeak   Peak position
%   fwhh    Full width at factor-of-height
%   xneg    Position of factor-of-height on lower x side
%   xpos    Position of factor-of-height on higher x side
%   ypeak   Peak height
%
% If there is no peak, then the return arguments are set to NaN.
% The occasions when this happens are
%  - The input arrays are empty or have only one point
%  - The peak value is at the first or last point

% Check option
if nargin==4
    outer=false;
elseif nargin~=5
    error('Check number of input arguments')
end
if fac<=0 || fac>=1
    error('Peak width search factor must lie in the range 0 < fac < 1')
end

% Check lengths of input arrays
np=numel(x);
if numel(y)~=np || numel(e)~=np
    error('x,y,e arrays must have equal lengths')
end

% Convert to column vectors
x=x(:); y=y(:); e=e(:);

% Remove points with infinite or NaN values
ok=isfinite(y(:))&isfinite(e(:));
if ~all(ok)
    x=x(ok); y=y(ok); e=e(ok);
    np=numel(x);
end

% Catch trivial case of empty arrays or one or two points (need at least three points to define a peak)
if np<3
    xcent=nan; xpeak=nan; fwhh=nan; xneg=nan; xpos=nan; ypeak=nan;
    return
end

% Find the points that straddle the half-height
[ymax,imax]=max(y);
xpeak=x(imax);
ypeak=y(imax);
if ~outer
    im=find((y(1:imax)-fac*ymax)<0, 1, 'last');
    ip=find((y(imax:end)-fac*ymax)<0, 1) + imax - 1;
else
    gt=(y(1:imax)-fac*ymax)>0;
    if numel(gt)>1
        im=find(diff(gt)==1, 1);
    else
        im=[];
    end
    gt=(y(imax:end)-fac*ymax)>0;
    if numel(gt)>1
        ip=find(diff(gt)==-1, 1, 'last') + imax;
    else
        ip=[];
    end
end

% ensure peak is defined
if isempty(im)||isempty(ip)
    xcent=nan; xpeak=nan; fwhh=nan; xneg=nan; xpos=nan;
    return
end

% interpolate to get half-height position
xneg = (x(im)*(y(im+1)-fac*ymax)+x(im+1)*(fac*ymax-y(im)))/(y(im+1)-y(im));
xpos = (x(ip-1)*(y(ip)-fac*ymax)+x(ip)*(fac*ymax-y(ip-1)))/(y(ip)-y(ip-1));

xcent = 0.5*(xneg+xpos);
fwhh = xpos-xneg;
