function [figureHandle, axesHandle, plotHandle] = ds2(w,varargin)
% Draw a surface plot of a 2D sqw dataset or array of datasets
%
%   >> ds2(w)       % Use error bars to set colour scale
%   >> ds2(w,wc)    % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%   >> ds2(...,xlo,xhi)
%   >> ds2(...,xlo,xhi,ylo,yhi)
%   >> ds2(...,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Differs from ds in that the signal sets the z axis, and the colouring is
% set by the error bars, or by another object. This enables two related
% functions to be plotted (e.g. dispersion relation where the 'signal'
% array holds the energy and the error array holds the spectral weight).
%
% Advanced use:
%   >> ds2(w,...,'name',fig_name)       % Draw with name = fig_name
%
%   >> ds2(w,...,'-noaspect')           % Do not change aspect ratio
%                                       % according to data axes unit lengths
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ds2(...)


% Check input arguments (must allow for the two cases of one or two plotting input arguments)
if ~isa(w,'sqw')
    error('Object to plot must be an sqw object or array of objects')
end

[ok,mess]=dimensions_match(w,2);
if ~ok, error(mess), end

% Strip trailing option, if present
[ok,mess,opt_adjust,opt_present]=adjust_aspect_option(varargin);
if ~ok, error(mess), end

nam=get_global_var('horace_plot','name_surface');
opt=struct('newplot',true,'default_name',nam,'lims_type','xyz');
[args,ok,mess,nw]=genie_figure_parse_plot_args2(opt,w,varargin{1:end-opt_present});
if ~ok, error(mess), end
if nw==2
    [figureHandle_, axesHandle_, plotHandle_] = ds2(IX_dataset_2d(w), IX_dataset_2d(varargin{1}), args{:});
else
    [figureHandle_, axesHandle_, plotHandle_] = ds2(IX_dataset_2d(w), args{:});
end

% Set aspect ratio
if adjust_aspect(w(1)) && opt_adjust
    pax = w(1).data.pax;
    dax = w(1).data.dax;                 % permutation of projection axes to give display axes
    ulen = w(1).data.ulen(pax(dax));     % unit length in order of the display axes
    energy_axis = 4;    % by convention in Horace
    if pax(dax(1))~=energy_axis && pax(dax(2))~=energy_axis    % both plot axes are Q axes
        aspect(ulen(1), ulen(2));
    end
    colorslider;        % redraw in case of aspect ratio change
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
