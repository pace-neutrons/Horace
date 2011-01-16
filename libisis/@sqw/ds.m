function [figureHandle, axesHandle, plotHandle] = ds(win,varargin)
% Surface plot for 2D dataset
%
%   >> ds(win)
%   >> ds(win,xlo,xhi)
%   >> ds(win,xlo,xhi,ylo,yhi)
% Or:
%   >> ds(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','jet')
% etc.
%
% See help for libisis/ds for more details of other options

% R.A. Ewings 14/10/2008

for i=1:numel(win)
    if dimensions(win(i))~=2
        if numel(win)==1
            error('sqw object is not two dimensional')
        else
            error('Not all elements in the array of sqw objects are two dimensional')
        end
    end
end

ixg_st_horace =  ixf_global_var('Horace','get','IXG_ST_HORACE');
[figureHandle_, axesHandle_, plotHandle_] = ds(IXTdataset_2d(win), 'name', ixg_st_horace.surface_name, 'tag', ixg_st_horace.tag, varargin{:});

pax = win(1).data.pax;
dax = win(1).data.dax;                 % permutation of projection axes to give display axes
ulen = win(1).data.ulen(pax(dax));     % unit length in order of the display axes
energy_axis = 4;    % by convention in Horace
if pax(dax(1))~=energy_axis && pax(dax(2))~=energy_axis    % both plot axes are Q axes
    aspect(ulen(1), ulen(2));
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
