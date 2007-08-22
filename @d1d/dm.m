function [fig_out, axes_out, plot_out] = dm(win,varargin)
%-------help for gtk marker plot command dm--------------------------------
% Function Syntax: 
% [figureHandle_,axesHandle_,plotHandle_] = 
% DM(w,[property_name,property_value]) or
% DM(w,xlo,xhi) or
% DM(w,xlo,xhi,ylo,yhi) 
%
% Output: figure,axes and plot handle
% Input: 1d dataset object and other control parameters (name value pairs)
%
% list of control propertie names
% >> ixf_default_properties('get','IXG_ST_DEFAULT.figure')
% >> ixf_default_properties('get','IXG_ST_DEFAULT.plot')
% >> ixf_default_properties('get','IXG_ST_DEFAULT.axes')
%
% you can also give axis limit for x and y 
% Purpose: plot the data according to values and control properties (for
% figure, axes and plot)
%
% Example: 
% DM(w) --> default structure plot
% DM(w,'Color','red') --> override default structure values 
% DM(w,'default','my_struct','Color','red') --> override values 
% DM(w,'default','my_struct') --> from structure
% DM(w,10,20)
% DM(w,10,20,0,200)
%
% See libisis graphics documentation for advanced syntax.
%--------------------------------------------------------------------------

%total
IXG_ST_HORACE = ixf_default_properties('get','IXG_ST_HORACE');
win_lib = convert_to_libisis(win);

for i = 1:numel(win)
    [title, xlab] = dnd_cut_titles (get(win(i)));
    win_lib(i).title = char(title);
    win_lib(i).x_units.units = char(xlab);
end

[figureHandle_, axesHandle_, plotHandle_] = dm(win_lib, 'name',IXG_ST_HORACE.oned_name, 'tag', IXG_ST_HORACE.tag, varargin{:});

if nargout > 0
    fig_out = figureHandle_;
    axes_out = axesHandle_;
    plot_out = plotHandle_;
end