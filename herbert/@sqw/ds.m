function [figureHandle, axesHandle, plotHandle] = ds(w,varargin)
% Draw a surface plot of a 2D sqw dataset or array of datasets
%
%   >> ds(w)
%   >> ds(w,xlo,xhi)
%   >> ds(w,xlo,xhi,ylo,yhi)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps(w,...) 

for i=1:numel(w)
    if dimensions(w(i))~=2
        if numel(w)==1
            error('sqw object is not two dimensional')
        else
            error('Not all elements in the array of sqw objects are two dimensional')
        end
    end
end
name_surface =  get_global_var('horace_plot','name_surface');

[figureHandle_, axesHandle_, plotHandle_] = ds(IX_dataset_2d(w), varargin{:}, 'name', name_surface);

pax = w(1).data.pax;
dax = w(1).data.dax;                 % permutation of projection axes to give display axes
ulen = w(1).data.ulen(pax(dax));     % unit length in order of the display axes
energy_axis = 4;    % by convention in Horace
if pax(dax(1))~=energy_axis && pax(dax(2))~=energy_axis    % both plot axes are Q axes
    aspect(ulen(1), ulen(2));
end

colorslider

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
