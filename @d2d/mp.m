function [fig_out, axes_out, plot_out] = mp(win,varargin)
% multiplot an array of d1d or single d2d
%
% Function Syntax: figure_handle = MP(w,['name',value,'tag',value,options])
%
% Output: figure, axes and plot handles
% Input: 
%   d1d:                    1d dataset object
%   Control Parameters:     property-value pairs of control parameters, eg.
%                           title, xlabel, afontcolor. See documentation
%                           for details
% Examples: 
%
% MP(w) 
% 
% This will multiplot w with default values for axes labels etc.
%
% MP(w,'name','tobie') 
% This will set the name of the multiplot to tobie
%
% MP(w,'name','tobie','tag','1d') 
% Thiw will set the name and tag of the plot.
%
%--------------------------------------------------------------------------
% I.Bustinduy 16/11/07

IXG_ST_HORACE =   ixf_global_var('Horace','get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);
win = get(win);

for i = 1:numel(win)
    [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = dnd_cut_titles (win(i));
    win_lib(i).title = char(title_main);
    win_lib(i).x_units.units = char(title_pax{1});
    win_lib(i).y_units.units = char(title_pax{2});
end

if(~isempty(IXG_ST_HORACE))
    [figureHandle_, axesHandle_, plotHandle_] = mp(win_lib, 'name',IXG_ST_HORACE.multiplot_name, 'tag', IXG_ST_HORACE.tag, varargin{:});
else
    [figureHandle_, axesHandle_, plotHandle_] = mp(win_lib, varargin{:});
end

if win.pax(1)~=energy_axis && win.pax(2)~=energy_axis    % both plot axes are Q axes
    x_ulen = din.ulen(win.pax(1));
    y_ulen = din.ulen(win.pax(2));
    aspect(x_ulen, y_ulen);
end

color_slider;

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end
