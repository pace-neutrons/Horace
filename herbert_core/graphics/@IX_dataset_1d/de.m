function [fig_handle, axes_handle, plot_handle] = de(w,varargin)
% Draws a plot of error bars of a spectrum or array of spectra
%
%   >> de(w)
%   >> de(w,xlo,xhi)
%   >> de(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> de(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = de(w,...) 


% Check input arguments
opt=struct('newplot',true,'lims_type','xy');
[args,ok,mess,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
type='e';
[fig_,axes_,plot_,ok,mess]=plot_oned (w,opt.newplot,type,fig,lims{:});
if ~ok, error(mess), end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
