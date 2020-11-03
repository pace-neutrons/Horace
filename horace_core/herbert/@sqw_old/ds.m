function [figureHandle, axesHandle, plotHandle] = ds(w,varargin)
% Draw a surface plot of a 2D sqw dataset or array of datasets
%
%   >> ds(w)
%   >> ds(w,xlo,xhi)
%   >> ds(w,xlo,xhi,ylo,yhi)
%   >> ds(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> ds(w,...,'name',fig_name)        % Draw with name = fig_name
%
%   >> ds(w,...,'-noaspect')            % Do not change aspect ratio
%                                       % according to data axes unit lengths
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ds(w,...)


[ok,mess]=dimensions_match(w,2);
if ~ok, error(mess), end

% Strip trailing option, if present
[ok,mess,opt_adjust,opt_present]=adjust_aspect_option(varargin);
if ~ok, error(mess), end

% Check input arguments
nam=get_global_var('horace_plot','name_surface');
opt=struct('newplot',true,'default_name',nam,'lims_type','xyz');
[args,ok,mess]=genie_figure_parse_plot_args(opt,varargin{1:end-opt_present});
if ~ok, error(mess), end

% Perform plot
[figureHandle_, axesHandle_, plotHandle_] = ds(IX_dataset_2d(w), args{:});

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
