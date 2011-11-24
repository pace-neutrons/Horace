function [figureHandle, axesHandle, plotHandle] = dd(win,varargin)
% Plot errorbars, markers, and line through data for 1d dataset.
%
%   >> dd(win)
%   >> dd(win,xlo,xhi)
%   >> dd(win,xlo,xhi,ylo,yhi)
% Or:
%   >> dd(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red')
% etc.
%
% See help for libisis/dd for more details of more options

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
[figureHandle_, axesHandle_, plotHandle_] = dd(IX_dataset_1d(win), 'name', name_oned, varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
