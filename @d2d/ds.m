function [fig_out, axes_out, plot_out] = ds(win,varargin)
%---------------help for gtk surface plot, ds command----------------------
%
% surface plot of a dataset_2d object (or array of dataset_1d objects) 
%
% Function Syntax: 
% [figureHandle_,axesHandle_,plotHandle_] = 
% DS(w,[property_name,property_value]) or
% DS(w,xlo,xhi) or
% DS(w,xlo,xhi,ylo,yhi)
%
% if plotting an ARRAY of dataset2d objects, set the separation property to
% 'seperate' by adding 'SEPARATIOIN','ON' to the optional arguments,
% otherwise the data will be combined and all points considered on the same
% graph  i.e.
%
% DS(w,'separation','on','color','red'); 
%
% if separation is off, the data will be interpolated and plotted at
% equally distributed points along the axes between the maxima and minima
% of the data, the number of points is the same as the number of datapoints
% in ALL the data, unless it reaches the maximum or is specified by
%
% DS(w,'noxvalues',xx,'noyvalues',yy);
%
% where xx and yy are the number of x points and y points respectively to
% plot. 
%
% Output: figure,axes and plot handle
% Input: 2d dataset object and other control parameters (name value pairs)
% list of control property names:
%
% >> ixf_ixf_global_var('get','IXG_ST_DEFAULT.figure')
% >> ixf_ixf_global_var('get','IXG_ST_DEFAULT.plot')
% >> ixf_ixf_global_var('get','IXG_ST_DEFAULT.axes')
% you can also give axis limit for x, y and z
%
% Purpose: plot the data on a surface according to values and control properties (for
% figure, axes and plot)
%
% Example: 
% DS(w) --> default structure plot
% DS(w,'Color','red') --> override default structure values 
% DS(w,'default','my_struct','Color','red') --> override values 
% DS(w,'default','my_struct') --> from structure
% DS(w,10,20)
% DS(w,10,20,0,200)
% DS(ww,10,20,0,400)
%
% See libisis graphics documentation for more information.
%-------------------updated 24/08/2006, Dean Whittaker---------------------

%total
IXG_ST_HORACE =  ixf_global_var('Horace','get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);
win = get(win);

for i = 1:numel(win)
    [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis] = dnd_cut_titles (win(i));
    win_lib(i).title = char(title_main);
    win_lib(i).x_units.units = char(title_pax{1});
    win_lib(i).y_units.units = char(title_pax{2});
end

[figureHandle_, axesHandle_, plotHandle_] = ds(win_lib, 'name',IXG_ST_HORACE.surface_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if win.pax(1)~=energy_axis && win.pax(2)~=energy_axis    % both plot axes are Q axes
    x_ulen = din.ulen(win.pax(1));
    y_ulen = din.ulen(win.pax(2));
    aspect(x_ulen, y_ulen);
end

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end