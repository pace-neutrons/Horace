function [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh(w,fac)
% Find centre of half-width half height in a IX_dataset_1d or array of IX_dataset_1d objects
%
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh(w,fac)
%
% Input:
%   w       mgenie spectrum
%   fac     Factor of peak height at which to determine the centre-height position
%           (default=0.5 i.e. centre-fwhh)
%   
% Output:
%   xcent   Centre of factor-of-height
%   xpeak   Peak position
%   ypeak   Peak height
%   fwhh    Full width at factor-of-height
%   xneg    Position of factor-of-height on lower x side
%   xpos    Position of factor-of-height on higher x side

if nargin==1
    fac=0.5;
end

nw = length(w);
if nw==1
    [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh_internal(w,fac);
    if isnan(xcent)
        warning('No peak defined by half-height points')
    end
else
    xpeak=zeros(size(w));
    xcent=zeros(size(w));
    fwhh=zeros(size(w));
    xneg=zeros(size(w));
    xpos=zeros(size(w));
    ypeak=zeros(size(w));
    for i=1:nw
        [xcent(i),xpeak(i),fwhh(i),xneg(i),xpos(i),ypeak(i)]=peak_cwhh_internal(w(i),fac);
        if isnan(xcent)
            warning(['No peak defined by half-height points - spectrum ',num2str(i)])
        end
    end
end
%---------------------------------------------------------------------------------------------------------
function [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peak_cwhh_internal(w,fac)
% centres of bins
if length(w.x)~=length(w.signal)
    xc=0.5*(w.x(1:end-1)+w.x(2:end));
else
    xc=w.x;
end

% Find the points that straddle the half-height
[ymax,imax]=max(w.signal);
xpeak=xc(imax);
ypeak=w.signal(imax);
im=max(find((w.signal(1:imax)-fac*ymax)<0));
ip=min(find((w.signal(imax:end)-fac*ymax)<0))+imax-1;

% ensure peak is defined
if isempty(im)||isempty(ip)
    xcent=nan; fwhh=nan; xneg=nan; xpos=nan;
    return
end

% interpolate to get half-height position
xneg = (xc(im)*(w.signal(im+1)-fac*ymax)+xc(im+1)*(fac*ymax-w.signal(im)))/(w.signal(im+1)-w.signal(im));
xpos = (xc(ip-1)*(w.signal(ip)-fac*ymax)+xc(ip)*(fac*ymax-w.signal(ip-1)))/(w.signal(ip)-w.signal(ip-1));

xcent = 0.5*(xneg+xpos);
fwhh = xpos-xneg;
