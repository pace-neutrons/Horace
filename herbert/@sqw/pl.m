function [figureHandle, axesHandle, plotHandle] = pl(win,varargin)
% Overplot line through data of a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pl(win)
%   >> pl(win,'color','red')
%
% See help for libisis\pl for more details of further options

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
if get(hor_config,'use_her_graph')
    name_oned = get(horgrph_config,'name_oned');
else
	name_oned =  get_global_var('horace_plot','name_oned');
end
name_oned =  get_global_var('horace_plot','name_oned');
[figureHandle_, axesHandle_, plotHandle_] = pl(IX_dataset_1d(win), 'name', name_oned, varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
