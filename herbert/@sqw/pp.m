function [figureHandle, axesHandle, plotHandle] = pp(win,varargin)
% Overplot errorbars and markers for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pp(win)
%   >> pp(win,'color','red')
%
% See help for libisis\pp for more details of further options

% R.A. Ewings 14/10/2008

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
[figureHandle_, axesHandle_, plotHandle_] = pp(IX_dataset_1d(win), 'name', name_oned, varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
