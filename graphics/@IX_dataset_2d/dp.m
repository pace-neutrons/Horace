function [fig_handle, axes_handle, plot_handle] = dp(w,varargin)
% Draws a plot of markers and error bars for an IX_dataset_2d or array of IX_dataset_2d
%
%   >> dp(w)
%   >> dp(w,xlo,xhi)
%   >> dp(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dp(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dp(w,...) 


% Check input arguments
opt=struct('newplot',true,'lims_type','xy');
[args,ok,mess]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
[fig_,axes_,plot_] = dp(IX_dataset_1d(w), args{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
