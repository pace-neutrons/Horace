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

IXG_ST_HORACE = ixf_default_properties('get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);
win = get(win);

for i = 1:numel(win)
    [title_main, xlab] = dnd_cut_titles (win(i));
    win_lib(i).title = char(title_main);
    win_lib(i).x_units.units = char(xlab);
end

[figureHandle_, axesHandle_, plotHandle_] = mp(win_lib, 'name',IXG_ST_HORACE.area_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end

