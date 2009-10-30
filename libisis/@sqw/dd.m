function [figureHandle_, axesHandle_, plotHandle_] = dd(win,varargin)
% Plot errorbars, markers, and line through data for 1d dataset.
%
%   >> dd(win)
%   >> dd(win,xlo,xhi);
%   >> dd(win,xlo,xhi,ylo,yhi);
% Or:
%   >> dd(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
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

ixg_st_horace =  ixf_global_var('Horace','get','IXG_ST_HORACE');
[figureHandle_, axesHandle_, plotHandle_] = dd(IXTdataset_1d(win), 'name', ixg_st_horace.oned_name, 'tag', ixg_st_horace.tag, varargin{:});
