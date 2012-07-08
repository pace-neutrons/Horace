function [figureHandle, axesHandle, plotHandle] = dh(win,varargin)
% Draws a histogram plot of a 1D sqw object or array of objects
%
%   >> dh(w)
%   >> dh(w,xlo,xhi)
%   >> dh(w,xlo,xhi,ylo,yhi)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dh(w,...) 

for i=1:numel(win)
    if dimensions(win(i))~=1
        if numel(win)==1
            error('sqw object is not one dimensional')
        else
            error('Not all elements in the array of sqw objects are one dimensional')
        end
    end
end
name_oned =  get_global_var('horace_plot','name_oned');

[figureHandle_, axesHandle_, plotHandle_] = dh(IX_dataset_1d(win), varargin{:}, 'name', name_oned);

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
