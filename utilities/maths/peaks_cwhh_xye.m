function [xcent,xpeak,fwhh,xneg,xpos,ypeak,imax,irange]=peaks_cwhh_xye(x,y,e,fac,varargin)
% Find centre of half height of the peaks in x-y-e data
%
%   >> [xcent,xpeak,fwhh,xneg,xpos,ypeak]=peaks_cwhh_xy(x,y,fac)
%   >> [...]=peaks_cwhh_xye(...,'opt1',arg1,'opt2',arg2,...)
%
% Input data where the y or e are infinite or NaN are eliminated before the peak search
%
% Input:
% ------
%   x       x values
%   y       signal
%   e       standard deviations on signal (set to empty to ignore)
%   fac     Factor of peak height at which to determine the centre-height position
%           (default=0.5 i.e. centre-fwhh)
%
% Peak search options:
%         'area', amin      Keep only those peaks whose area is at least the given value
%     'rel_area', rel_amin  Keep only those peaks whose area is at least a fraction
%                          rel_amin of the largest peak
%       'height', hmin      Keep only those peaks whose height is at least the given value
%   'rel_height', rel_hmin  Keep only those peaks whose height is at least a fraction
%                          rel_hmin of the tallest peak
%   'err_height', herr_fac  Keep only those peaks whose height above the defining boundaries
%                          determined by input argument fac is at least a factor
%                          herr_fac larger than the error bar on the height difference
%
% In addition with the above, or on their own:
%           'na', nmax      Keep nmax peaks with largest areas (cannot use with 'nh')
%           'nh', nmax      Keep nmax tallest peaks (cannot use with 'na')
%   
%   
% Output:
% -------
%   xcent   Centre of factor-of-height [column vector]
%   xpeak   Peak position [column vector]
%   fwhh    Full width at factor-of-height [column vector]
%   xneg    Position of factor-of-height on lower x side [column vector]
%   xpos    Position of factor-of-height on higher x side [column vector]
%   ypeak   Peak height [column vector]
%
% If there is no peak, then the return arguments are set to zeros(0,1) i.e. empty
% The occasions when this happens are
%  - The input arrays are empty or have only one point or two points 
%  - The only peak value(s) are at the first or last point


% Check input
% -----------------------------------------------------
% Check fac
if fac<=0 || fac>=1
    error('Peak width search factor must lie in the range 0 < fac < 1')
end

% Check options
narg=numel(varargin);
if rem(narg,2)~=0
    error('Check the number of optional arguments')
end
rel_arange=[];
arange=[];
rel_hrange=[];
hrange=[];
herr_fac=[];
na=[];
nh=[];
for i=1:2:narg
    if is_string(varargin{i}) && ~isempty(varargin{i})
        if strcmpi(varargin{i},'rel_area')
            rel_arange=varargin{i+1};
            if ~(isnumeric(rel_arange) && numel(rel_arange)==2 && diff(rel_arange)>0 && rel_arange(1)>=0 && rel_arange(2) <=1)
                error('Peak relative area range must have 0 =< amin < amax =< 1')
            end
        elseif strcmpi(varargin{i},'area')
            arange=varargin{i+1};
            if ~(isnumeric(arange) && numel(arange)==2 && diff(arange)>0 && arange(1)>=0)
                error('Peak area range must have 0 =< amin < amax')
            end
        elseif strcmpi(varargin{i},'rel_height')
            rel_hrange=varargin{i+1};
            if ~(isnumeric(rel_hrange) && numel(rel_hrange)==2 && diff(rel_hrange)>0 && rel_hrange(1)>=0 && rel_hrange(2) <=1)
                error('Peak relative height range must have 0 =< hmin < hmax =< 1')
            end
        elseif strcmpi(varargin{i},'height')
            hrange=varargin{i+1};
            if ~(isnumeric(hrange) && numel(hrange)==2 && diff(hrange)>0 && hrange(1)>=0)
                error('Peak height range must have 0 =< hmin < hmax')
            end
        elseif strcmpi(varargin{i},'err_height')
            herr_fac=varargin{i+1};
            if herr_fac<=0
                error('Peak height as a multiple of error bar must be greater than zero')
            end
            if isempty(e)
                error('Must have error bars to determine peak height as a multiple of error on peak height')
            end
        elseif strcmpi(varargin{i},'na')
            na=varargin{i+1};
            if na<=0
                error('Number of peaks to be retained must be greater than zero')
            end
        elseif strcmpi(varargin{i},'nh')
            nh=varargin{i+1};
            if nh<=0
                error('Number of peaks to be retained must be greater than zero')
            end
        end
    else
        error('Options must have form ...''keyword'',value,...')
    end
end
if ~isempty(na) && ~isempty(nh)
    error('Can keep largest peaks by area criterion or height criterion, but not both')
end

% Check lengths of input arrays
np=numel(x);
ne=numel(e);
if ne>0
    if numel(y)~=np || numel(e)~=np
        error('x,y,e arrays must have equal lengths')
    end
else
    if numel(y)~=np
        error('x,y arrays must have equal lengths')
    end
end

% Convert to column vectors
x=x(:); y=y(:); e=e(:);

% Remove points with infinite or NaN values
if ne>0
    ok=isfinite(y(:))&isfinite(e(:));
else
    ok=isfinite(y(:));
end
if ~all(ok)
    x=x(ok); y=y(ok);
    np=numel(x);
end


% Main algorithm
% -----------------------------------------------------
% Find indicies of points that are local maxima (need at least three points to define a peak)
if np>3
    imax=find_maxima(y);
else
    imax=[];
end

% Fill output arguments
npk=numel(imax);
xcent=NaN(npk,1);
xpeak=NaN(npk,1);
fwhh=NaN(npk,1);
xneg=NaN(npk,1);
xpos=NaN(npk,1);
ypeak=NaN(npk,1);
irange=[npk,2];

if isempty(imax)    % case of no peaks or not enough data points
    return
end

% Get peak positions
for i=1:npk
    [irange(i,1),irange(i,2),xcent(i),xpeak(i),fwhh(i),xneg(i),xpos(i)]=peak_cwhh_xy(x,y,fac,imax(i));
end
ind_ok=find(~isnan(xcent));   % defined peaks
if numel(ind_ok)>1
    [irange_ok,ix]=sortrows(irange(ind_ok,:));
    keep=[true;~all(irange_ok(2:end,:)==irange_ok(1:end-1,:),2)];  % Remove coincident peaks
    ikeep=ind_ok(ix(keep));
    xcent=xcent(ikeep);
    xpeak=xpeak(ikeep);
    fwhh=fwhh(ikeep);
    xneg=xneg(ikeep);
    xpos=xpos(ikeep);
    ypeak=y(imax(ikeep));
    imax=imax(ikeep);
    irange=irange(ikeep,:);
    % Check: logic says that none of the ranges should be contiguous
    if sum(keep)>1 && any(irange(2:end,1)<irange(1:end-1,2))
        disp('Logic error!')
    end
end
npk=numel(imax);
area=zeros(npk,1);
area_err=zeros(npk,1);
for i=1:npk
    [area(i),area_err(i)]=peak_integral(x,y,e,irange(i,1),irange(i,2));
end
%area=ypeak.*fwhh;

% Filter peaks on optional criteria
if npk>1 && (~isempty(rel_arange) || ~isempty(arange) || ~isempty(rel_hrange) || ~isempty(hrange) || ~isempty(herr_fac))
    ok=true(size(imax));
    if ~isempty(rel_arange)
        ok=ok & ((area./max(area))>=rel_arange(1)) & ((area./max(area))<=rel_arange(2));
    end
    if ~isempty(arange)
        ok=ok & (area>=arange(1)) & (area<=arange(2));
    end
    if ~isempty(rel_hrange)
        ok=ok & (ypeak/max(ypeak)>=rel_hrange(1)) & (ypeak/max(ypeak)<=rel_hrange(2));
    end
    if ~isempty(hrange)
        ok=ok & (ypeak>=hrange(1)) & (ypeak<=hrange(2));
    end
    if ~isempty(herr_fac)
        herr_fac_lo=(ypeak-y(irange(:,1)))./sqrt(e(imax).^2+e(irange(:,1)).^2);
        herr_fac_hi=(ypeak-y(irange(:,2)))./sqrt(e(imax).^2+e(irange(:,2)).^2);
        ok=ok & (herr_fac_lo>=herr_fac & herr_fac_hi>=herr_fac);
    end
    xcent=xcent(ok);
    xpeak=xpeak(ok);
    fwhh=fwhh(ok);
    xneg=xneg(ok);
    xpos=xpos(ok);
    ypeak=ypeak(ok);
    imax=imax(ok);
    irange=irange(ok,:);
    area=area(ok);
end

% Pick out a restricted number of peaks
npk=numel(imax);    % we may have filtered out some peaks since last got npk
ind=[];
if ~isempty(na) && na<npk
    [asort,ix]=sort(area);
    ind=ix(end-na+1:end);
elseif ~isempty(nh)
    [ysort,ix]=sort(ypeak);
    ind=ix(end-na+1:end);
end
if ~isempty(ind)
    ind=sort(ind);
    xcent=xcent(ind);
    xpeak=xpeak(ind);
    fwhh=fwhh(ind);
    xneg=xneg(ind);
    xpos=xpos(ind);
    ypeak=ypeak(ind);
    imax=imax(ind);
    irange=irange(ind,:);
    area=area(ind);
end


%========================================================================================
function imax=find_maxima(yin)
% Find indicies of points in a column array that are local maxima.
% Repeated points are first removed, so flat topped peaks are also found

ok=[true;diff(yin)~=0];   % find non-repeated values
y=yin(ok);

sgn=sign(diff(y));
ind=1+find(sgn(1:end-1)>0 & sgn(2:end)<0);
ix=find(ok);
imax=ix(ind);


%========================================================================================
function [im,ip,xcent,xpeak,fwhh,xneg,xpos]=peak_cwhh_xy(x,y,fac,imax)
% Find peak width and position given the location of a local maximum
%
%   >> 
%
% Input:
% ------
%   x       x values
%   y       signal
%   fac     Factor of peak height at which to determine the centre-height position
%           (default=0.5 i.e. centre-fwhh)
%   imax    Index of position of local maximum in y array
%   
% Output:
% -------
%   im      Index of last earlier point below (fac * peak value)
%   ip      Index of first later point below (fac * peak value)
%   xcent   Centre of factor-of-height
%   xpeak   Peak position
%   fwhh    Full width at factor-of-height
%   xneg    Position of factor-of-height on lower x side
%   xpos    Position of factor-of-height on higher x side
%   ypeak   Peak height
%
% If a peak is not found with y(imax) as the peak value then im,ip...ypeak all set to NaN

xpeak=x(imax);
ymax=y(imax);

im=find((y(1:imax)-fac*ymax)<0, 1, 'last');
ip=find((y(imax:end)-fac*ymax)<0, 1) + imax - 1;

% Ensure peak is defined with imax as a maximum
if isempty(im) || isempty(ip) || any(y(im:ip)>ymax)
    im=NaN; ip=NaN;
    xcent=NaN; xpeak=NaN; fwhh=NaN; xneg=NaN; xpos=NaN;
    return
end

% interpolate to get half-height position
xneg = (x(im)*(y(im+1)-fac*ymax)+x(im+1)*(fac*ymax-y(im)))/(y(im+1)-y(im));
xpos = (x(ip-1)*(y(ip)-fac*ymax)+x(ip)*(fac*ymax-y(ip-1)))/(y(ip)-y(ip-1));

xcent = 0.5*(xneg+xpos);
fwhh = xpos-xneg;


%========================================================================================
function [A,sig_A]=peak_integral(x,y,e,imin,imax)
% Simple trapezoidal integral between two limits, subtracting a 'background'
% defined as the linear interpolation between the bounds.

% Area of peak between range
[sout,eout]=integrate_1d_points(x(:),y(:),e(:),[x(imin),x(imax)]);
% Area under straight line between end points of range
[sbk,ebk]=integrate_1d_points([x(imin);x(imax)],[y(imin);y(imax)],[e(imin);e(imax)],[x(imin),x(imax)]);

A=sout-sbk;
sig_A=sqrt(eout^2+ebk^2);
