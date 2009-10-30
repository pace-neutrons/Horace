function [figureHandle_, axesHandle_, plotHandle_] = de(win,varargin)
% Plot errorbars for 1d dataset.
%
%   >> de(win)
%   >> de(win,xlo,xhi);
%   >> de(win,xlo,xhi,ylo,yhi);
% Or:
%   >> de(win,'xlim',[xlo,xhi],'ylim',[ylo,yhi],'Color','red');
%
% See help for libisis/de for more details of more options

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
[figureHandle_, axesHandle_, plotHandle_] = de(IXTdataset_1d(win), 'name', ixg_st_horace.oned_name, 'tag', ixg_st_horace.tag, varargin{:});
