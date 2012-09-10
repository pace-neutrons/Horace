function [yout, eout] = unspike_xye (xin,yin,ein,varargin)
% Remove points deemed spikes from x-y-e data, and replace with values interpolated between good points
%
%   >> [yout, eout] = unspike_xye (xin,yin,ein,ymin,ymax,fac,sfac)
%
% Input:
% ------
%   xin     x coordinates of points
%   yin     signal values
%   ein     standard deviations
%   ymin    Lower filter (all points less than this will be removed) NaN or -Inf to ignore (default)
%   ymax    Upper filter (all points greater than this will be removed) NaN or Inf to ignore (default)
%   fac     Peak threshold factor (default=2):
%               A point is a spike if signal is smaller or larger than both neighbours by this factor,
%              all three signals with same sign and satisfies 
%   sfac    Peak fluctuation threshold (default=5):
%               A point is a spike if differs from it neighbours by this factor of standard deviations,
%              differeing by the same sign
%
%   Both the peak threshold and peak fluctuation criteria must be satisfied.
%
% Output:
% -------
%   yout    Unspiked signal values (obtained by linear interpolation between nearest good flanking points)
%   eout    Unspiked standard deviations (error estimated on interpolated values)
% 
%
% Input arrays will be converted to vectors internally, and then reshaped to original 
% shape on exit.
%
%
% Definition of a spike
% ----------------------
% A spike is a single point that is markedly higher or lower than its immediate neighbours.
% The signal is replaced by the linear interpolation between the nearest unremoved
% neighbouring points. Before this filtering is perfomed, those points which lie outside
% the range ymin to ymax are removed (if one of both of these limits are given).
% 
% The algorithm assumes that spikes are isolated. A spike is a point which
%  (1) differs (with the same sign of the deviations) from both of its neighbours by more
%     than sfac standard deviations
% and at the same time:
%  (2) has the same sign and is more than fac times bigger in absolute magnitude than both
%     its neighbours
% 
% The second condition is to avoid the summit point of a high statistics peak being treated as
% a spike. It is not entirely robust - if the yscale is offset by 90% of the peak so that only the
% top three points are above the x-axis, the 1st and 3rd only just above, then condition (2)
% will be fooled and the central point considered a spike. However, for the purposes for which
% this routine is intended (raw counts or first-line analysis) this circumstance will not
% usually arise.

% Check lengths of input arrays
np=numel(xin);
if numel(yin)~=np || numel(ein)~=np
    error('x,y,e arrays must have equal lengths')
end
% Catch trivial case of empty arrays
if np==0
    yout=yin;
    eout=ein;
    return
end
% Convert to column vectors
if size(xin,1)~=np
    xin=xin(:);
end
reshape_y=false;
if size(yin,1)~=np
    reshape_y=true;
    yin=yin(:);
end
reshape_e=false;
if size(ein,1)~=np
    reshape_e=true;
    ein=ein(:);
end

narg=numel(varargin);
if narg<1 || isempty(varargin{1}), ymin=NaN; else ymin=varargin{1}; end
if narg<2 || isempty(varargin{2}), ymax=NaN; else ymax=varargin{2}; end
if narg<3 || isempty(varargin{3}), fac=2;  else fac=abs(varargin{3}); end
if narg<4 || isempty(varargin{4}), sfac=5; else sfac=abs(varargin{4}); end

% Remove points outside the acceptable range
filter_low =~(isnan(ymin)||(ymin==-Inf));
filter_high=~(isnan(ymax)||(ymax==Inf));
if ~filter_low && ~filter_high
    ind_ok=(1:numel(xin))';
    x=xin; y=yin; e=ein;
else
    if filter_low && filter_high
        ok=(yin>=ymin)&(yin<=ymax);
    elseif filter_low
        ok=(yin>=ymin);
    elseif filter_high
        ok=(yin<=ymax);
    end
    ind_ok=find(ok);
    x=xin(ok); y=yin(ok); e=ein(ok);
end

% Remove spikes if three or more points
if numel(x)>=3
    y0=y(2:end-1);  e0=e(2:end-1);
    ylo=y(1:end-2); elo=e(1:end-2);
    yhi=y(3:end);   ehi=e(3:end);
    dlo=y0-ylo;
    dhi=y0-yhi;
    bad_sigma= sign(dlo)==sign(dhi) & abs(dlo)>sfac*sqrt(e0.^2+elo.^2) & abs(dhi)>sfac*sqrt(e0.^2+ehi.^2);
    bad_dev  = sign(y0).*sign(ylo)>=0 & sign(y0).*sign(yhi)>=0 & ...
        ((abs(y0)>fac*abs(ylo) & abs(y0)>fac*abs(yhi)) | (abs(y0)<(1/fac)*abs(ylo) & abs(y0)<(1/fac)*abs(yhi)));
    ok=[true;~bad_sigma|~bad_dev;true];
    ind_ok=ind_ok(ok);
    x=x(ok); y=y(ok); e=e(ok);
end

% Interpolate to fill removed points (catch special cases of 0,1 or 2 points left)
if numel(x)==0
    yout=NaN(size(yin));
    eout=NaN(size(ein));
    return
elseif numel(x)==1
    yout=y*ones(size(yin));
    eout=e*ones(size(ein));
    return
else
    % Get indicies of points to interpolate/extrapolate
    ok=false(np,1);
    ok(ind_ok)=true;    % true for points in xin that are retained
    sum_ok=cumsum(ok);  % indexing into this array will yield 
    ind_bad=find(~ok);  % indicies of points in xin that are bad
    ix_lo=sum_ok(ind_bad);     % indicies into ind_ok of the closest good point to left of each bad point
    ind_extrap_lo=ind_bad(ix_lo==0);               % indicies of points in xin for which to simply use y,e for
                                                    % leftmost good point, as cannot perform interpolation
    ind_extrap_hi=ind_bad(ix_lo==numel(ind_ok));   % indicies of points in xin for which to simply use y,e for
                                                    % rightmost good point, as cannot perform interpolation
    i_interp=(ix_lo>0 & ix_lo<numel(ind_ok));% true indicates which elements of ix_lo will be used in interpolation
    ind_interp=ind_bad(i_interp);
    ind_interp_lo=ind_ok(ix_lo(i_interp));
    ind_interp_hi=ind_ok(ix_lo(i_interp)+1);
    % Fill output arrays, by interpolation or extrapolation as required
    yout=yin;
    eout=ein;
    if ~isempty(ind_extrap_lo)
        yout(ind_extrap_lo)=yin(ind_ok(1));
        eout(ind_extrap_lo)=ein(ind_ok(1));
    end
    if ~isempty(ind_extrap_hi)
        yout(ind_extrap_hi)=yin(ind_ok(end));
        eout(ind_extrap_hi)=ein(ind_ok(end));
    end
    if ~isempty(ind_interp)
        [yout(ind_interp),eout(ind_interp)]=interpolate(xin(ind_interp_lo),yin(ind_interp_lo),ein(ind_interp_lo),...
                                                    xin(ind_interp_hi),yin(ind_interp_hi),ein(ind_interp_hi),xin(ind_interp));
    end
    if reshape_y, yout=reshape(yout,size(yin)); end
    if reshape_e, eout=reshape(eout,size(ein)); end
end

%--------------------------------------------------------------------------------------------------
function [y,e]=interpolate(x1,y1,e1,x2,y2,e2,x)
a1=(x2-x)./(x2-x1);
a2=(x-x1)./(x2-x1);
y=a1.*y1+a2.*y2;
e=sqrt((a1.*e1).^2+(a2.*e2).^2);
