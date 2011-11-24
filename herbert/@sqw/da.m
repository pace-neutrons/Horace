function [figureHandle, axesHandle, plotHandle] = da(win,varargin)
% Area plot for 2D dataset
%
%   >> da(win)
%   >> da(win,xlo,xhi)
%   >> da(win,xlo,xhi,ylo,yhi)
% Or:
%   >> da(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'colormap','bone')
% etc.
%
% See help for libisis/da for more details of other options

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
if get(hor_config,'use_her_graph')
    name_area = get(horgrph_config,'name_area');
else
	name_area =  get_global_var('horace_plot','name_area');
end
[figureHandle_, axesHandle_, plotHandle_] = da(IX_dataset_2d(win), 'name', name_area, varargin{:});

pax = win(1).data.pax;
dax = win(1).data.dax;                 % permutation of projection axes to give display axes
ulen = win(1).data.ulen(pax(dax));     % unit length in order of the display axes
energy_axis = 4;    % by convention in Horace
if pax(dax(1))~=energy_axis && pax(dax(2))~=energy_axis    % both plot axes are Q axes
    aspect(ulen(1), ulen(2));
end

colorslider;

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
