function [fig_handle, axes_handle, plot_handle] = plotover(w,varargin)
% Overplot an area plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> plotover(w)
%
% Advanced use:
%   >> plotover(w,'name',fig_name)  % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = plotover(w,...) 
%
%
% Synonym for:
%   >> pa(...)

% Check input arguments
opt=struct('newplot',false);
[args,ok,mess,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
type='area';
[fig_,axes_,plot_,ok,mess]=plot_twod (w,opt.newplot,type,fig);
if ~ok, error(mess), end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
