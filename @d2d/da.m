function [fig_out, axes_out, plot_out] = da(win,varargin)
%--------help for gtk area plot da command---------------------------------
%
% Area plot of dataset_2d (or array of d1d)
%
% Function Syntax: 
% [figureHandle_,axesHandle_,plotHandle_] = 
% DA(w,[property_name,property_value]) or
% DA(w,xlo,xhi) or
% DA(w,xlo,xhi,ylo,yhi)
%
% Output: figure,axes and plot handle
% Input: 2d dataset object and other control parameters (name value pairs)
% list of control propertie names:
%
% >>IXG_ST_DEFAULT.figure
% >>IXG_ST_DEFAULT.plot
% >>IXG_ST_DEFAULT.axes
% you can also give axis limit for x, y and z
%
% Purpose: plot the data according to values and control properties (for
% figure, axes and plot)
%
% Example: 
% DA(w) --> default structure plot
% DA(w,'Color','red') --> override default structure values 
% DA(w,'default','my_struct','Color','red') --> override values 
% DA(w,'default','my_struct') --> from structure
% DA(w,10,20)
% DA(w,10,20,0,200)
%
% See the libisis graphics documentaiton for more information.
%-------------------updated 17/05/2007, Dean Whittaker---------------------
%total

IXG_ST_HORACE = ixf_default_properties('get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);
win = get(win);

for i = 1:numel(win)
    [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = dnd_cut_titles (win(i));
    win_lib(i).title = char(title_main);
    win_lib(i).x_units.units = char(title_pax{1});
    win_lib(i).y_units.units = char(title_pax{2});
end

[figureHandle_, axesHandle_, plotHandle_] = da(win_lib, 'name',IXG_ST_HORACE.area_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if win.pax(1)~=energy_axis && win.pax(2)~=energy_axis    % both plot axes are Q axes
    x_ulen = win.ulen(win.pax(1));
    y_ulen = win.ulen(win.pax(2));
    aspect(x_ulen, y_ulen);
end

color_slider;

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end
