function [fig_handle, axes_handle, plot_handle] = pm(w,varargin)
% Overplot markers for a spectrum or array of spectra on an existing plot
%
%   >> pm(w)
%
% Advanced use:
%   >> pm(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pm(w,...) 


% Check input arguments
opt=struct('newplot',false);
[args,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});

% Perform plot
type='m';
[fig_,axes_,plot_]=plot_oned (w,opt.newplot,type,fig);

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end