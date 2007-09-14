function [fig_out, axes_out, plot_out] = dp(win,varargin)
%----------------help for gtk dp errorbar and marker plot command----------
%
% purpose: plot markers and errorbars.
% 
% Function Syntax: 
% [ figureHandle_,axesHandle_,plotHandle_] = 
% DP(w,[property_name,property_value]) or
% DP(w,xlo,xhi) or
% DP(w,xlo,xhi,ylo,yhi)
%
% Output: figure,axes and plot handle matrix - figure/axes/plotHandle_(:,1)
% are handles to the errorbars, figure/axes/plotHandle_(:,2) are handles to
% the markers
%
% Input: 1d dataset object and other control parameters (name value pairs)
% you can also give axis limit for x and y 
% Purpose: plot the data according to values and control properties (for
% figure, axes and plot)
%
% Examples: 
% DP(w) --> default structure plot
% DP(w,'Color','red') --> override default structure values 
% DP(w,'default','my_struct','Color','red') --> override values 
% DP(w,'default','my_struct') --> from structure
% DP(w,10,20)
% DP(w,10,20,0,200)
%
% See libisis graphics documentation for advanced syntax.
%--------------------------------------------------------------------------



IXG_ST_HORACE =   ixf_global_var('Horace','get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);

for i = 1:numel(win)
    [title, xlab] = dnd_cut_titles (get(win(i)));
    win_lib(i).title = char(title);
    win_lib(i).x_units.units = char(xlab);
end

[figureHandle_, axesHandle_, plotHandle_] = dp(win_lib, 'name',IXG_ST_HORACE.oned_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end