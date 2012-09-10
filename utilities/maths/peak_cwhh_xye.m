function [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh_xye(x,y,e,fac)
% Find centre of half-width half height in a IX_dataset_1d or array of IX_dataset_1d objects
%
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh(w,fac)
%
% Input:
% ------
%   x       x values
%   y       signal
%   e       standard deviations on signal
%   fac     Factor of peak height at which to determine the centre-height position
%           (default=0.5 i.e. centre-fwhh)
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


% Check lengths of input arrays
np=numel(x);
if numel(y)~=np || numel(e)~=np
    error('x,y,e arrays must have equal lengths')
end
% Catch trivial case of empty arrays or one point
if np==0
    xcent=nan; xpeak=nan; fwhh=nan; xneg=nan; xpos=nan;
    return
elseif np==1
    xcent=nan; xpeak=nan; fwhh=nan; xneg=nan; xpos=nan;
    return
end
% Convert to column vectors
if size(x,1)~=np
    x=x(:);
end

if size(y,1)~=np
    y=y(:);
end

if size(e,1)~=np
    e=e(:);
end

% Find the points that straddle the half-height
[ymax,imax]=max(y);
xpeak=x(imax);
ypeak=y(imax);
im=find((y(1:imax)-fac*ymax)<0, 1, 'last' );
ip=find((y(imax:end)-fac*ymax)<0, 1 )+imax-1;

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
