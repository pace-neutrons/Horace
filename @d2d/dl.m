function [fig_out, axes_out, plot_out] = dl(win,varargin)
%--------help for gtk line plot command dl --------------------------------
% Function Syntax: 
% [figureHandle_,axesHandle_,plotHandle_] = 
% DL(w,[property_name,property_value]) or
% DL(w,xlo,xhi) or
% DL(w,xlo,xhi,ylo,yhi)
%
% Output: figure,axes and plot handle
% Input: 1d dataset object and other control parameters (name value pairs)
%
% you can also give axis limit for x and y 
% Purpose: plot the data according to values and control properties (for
% figure, axes and plot)
%
% Example: 
% DL(w) --> default structure plot
% DL(w,'Color','red') --> override default structure values 
% DL(w,'default','my_struct','Color','red') --> override values 
% DL(w,'default','my_struct') --> from structure
% DL(w,10,20)
% DL(w,10,20,0,200)
%
% See libisis graphics documentation for advanced syntax.
%--------------------------------------------------------------------------

%total


IXG_ST_HORACE =   ixf_global_var('Horace','get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);

for i = 1:numel(win)
    [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = dnd_cut_titles (win(i));
    win_lib(i).title = char(title_main);
    win_lib(i).x_units.units = char(title_pax{1});
    win_lib(i).y_units.units = char(title_pax{2});
end


[figureHandle_, axesHandle_, plotHandle_] = dl(win_lib, 'name',IXG_ST_HORACE.oned_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end


