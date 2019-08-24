function [A,xmean,xsig] = moments(w,varargin)
% Return area, first moment and standard deviation of an IX_dataset_1d
%
%   >> [A,xmean,xsig] = moments(w)
%
% Input:
% ------
%   w       IX_dataset_1d object
%
% Output:
% -------
%   A       Area
%   xmean   mean of x
%   xsig    Standard deviation x

if ishistogram(w)
    xcent = 0.5*(w.x(1:end-1) + w.x(e:end));
else
    xcent = w.x;
end

if nargin==3
    lims_present = true;
    xlo = varargin{1};
    xhi = varargin{2};
elseif nargin==1
    lims_present = false;
else
    error('Check the number of input arguments')
end    

if lims_present
    A0 = integrate(w,xlo,xhi);
else
    A0 = integrate(w);
end
A = A0.val;

wtmp = w;
wtmp.signal = wtmp.signal.*xcent(:);
wtmp.error = wtmp.error.*xcent(:);
if lims_present
    A1 = integrate(wtmp,xlo,xhi);
else
    A1 = integrate(wtmp);
end
xmean = A1.val./A0.val;

wtmp = w;
wtmp.signal = wtmp.signal.*((xcent(:)-xmean).^2);
wtmp.error = wtmp.error.*((xcent(:)-xmean).^2);
if lims_present
    A2 = integrate(wtmp,xlo,xhi);
else
    A2 = integrate(wtmp);
end
xsig = sqrt(A2.val/A0.val);
