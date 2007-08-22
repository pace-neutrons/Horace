function [fig_out, axes_out, plot_out] = de(win,varargin)
% ----help for gtk errorbar plot function de-------------------------------
% Function Syntax: 
% [figureHandle_,axesHandle_,plotHandle_] = 
% DE(w,[property_name,property_value]) or
% DE(w,xlo,xhi) or
% DE(w,xlo,xhi,ylo,yhi)
%
% Output: figure,axes and plot handle
% Input: 1d dataset object and other control parameters (name value pairs)
%
% list of control propertie names
% >> ixf_default_properties('get','IXG_ST_DEFAULT.figure')
% >> ixf_default_properties('get','IXG_ST_DEFAULT.plot')
% >> ixf_default_properties('get','IXG_ST_DEFAULT.axes')
% you can also give axis limit for x and y 
%
% Purpose: plot the data according to values and control properties (for
% figure, axes and plot)
%
% Example: 
% DE(w) --> default structure plot
% DE(w,'Color','red') --> override default structure values 
% DE(w,'default','my_struct','Color','red') --> override values 
% DE(w,'default','my_struct') --> from structure
% DE(w,10,20)
% DE(w,10,20,0,200)
%
% See libisis graphics documentation for advanced syntax.
%--------------------------------------------------------------------------

%total
IXG_ST_HORACE = ixf_default_properties('get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);

for i = 1:numel(win)
    [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = dnd_cut_titles (win(i));
    win_lib(i).title = char(title_main);
    win_lib(i).x_units.units = char(title_pax{1});
    win_lib(i).y_units.units = char(title_pax{2});
end


[figureHandle_, axesHandle_, plotHandle_] = de(win_lib, 'name',IXG_ST_HORACE.oned_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end
