function [figureHandle, axesHandle, plotHandle] = mp(win,varargin)
% Multiplot data for 2D dataset or array of 1D datasets
%
%   >> mp(win)
%   >> mp(win,xlo,xhi)
%   >> mp(win,xlo,xhi,ylo,yhi)
% Or:
%   >> mp(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'color','red')
% etc.
%
% See help for libisis/mp for more details of other options

% R.A. Ewings 14/10/2008

nd=zeros(size(win));
for n=1:numel(win)
    nd(n)=dimensions(win(n));
end

% Check is 1D or 2D (no other dimensionality has mp implemented)
if all(nd==1)
    w=IXTdataset_1d(win);
elseif all(nd==2)
    w=IXTdataset_2d(win);
elseif any(nd~=nd(1))
    error('All elements of array must be datasets of the same dimensionality');
else
    error('Error - mp only works for 1D or 2D datasets');
end

ixg_st_horace =  ixf_global_var('Horace','get','IXG_ST_HORACE');
[figureHandle_, axesHandle_, plotHandle_] = mp(w, 'name', ixg_st_horace.multiplot_name, 'tag', ixg_st_horace.tag, varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
