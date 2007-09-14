function [fig_out, axes_out, plot_out] = dd(win,varargin)
%----------------help for gtk dp errorbar and marker plot------------------
%
% purpose: plot errorbars, markers and line through the data
% 
% Function Syntax: 
% [ figureHandle_,axesHandle_,plotHandle_] = 
% DD(w,[property_name,property_value]) or
% DD(w,xlo,xhi) or
% DD(w,xlo,xhi,ylo,yhi)
%
% Output: figure,axes and plot handle matrix - figure/axes/plotHandle_(:,1)
% are handles to the errorbars, figure/axes/plotHandle_(:,2) are handles to
% the markers, figure/axes/plotHandle_(:,3) are handles to the lines
%
% Input: 1d dataset object and other control parameters (name value pairs)
% you can also give axis limit for x and y 
%
% Purpose: plot the data according to values and control properties (for
% figure, axes and plot)
%
% Example: 
% DD(w) --> default structure plot
% DD(w,'Color','red') --> override default structure values 
% DD(w,'default','my_struct','Color','red') --> override values 
% DD(w,'default','my_struct') --> from structure
% DD(w,10,20)
% DD(w,10,20,0,200)
%
% See libisis graphics documentation for advanced syntax.
%--------------------------------------------------------------------------

IXG_ST_HORACE =  ixf_global_var('Horace','get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);

for i = 1:numel(win)
    [title, xlab] = dnd_cut_titles (get(win(i)));
    win_lib(i).title = char(title);
    win_lib(i).x_units.units = char(xlab);
end

[figureHandle_, axesHandle_, plotHandle_] = dd(win_lib, 'name',IXG_ST_HORACE.oned_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end


