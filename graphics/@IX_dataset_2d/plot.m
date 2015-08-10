function [fig_handle, axes_handle, plot_handle] = plot(w,varargin)
% Draw an area plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> plot(w)
%   >> plot(w,xlo,xhi)
%   >> plot(w,xlo,xhi,ylo,yhi)
%   >> plot(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> plot(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = plot(w,...) 
%
%
% Synonym for:
%   >> da(...)


% Check input arguments
opt=struct('newplot',true,'lims_type','xyz');
[args,ok,mess,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
type='area';
[fig_,axes_,plot_,ok,mess]=plot_twod (w,opt.newplot,type,fig,lims{:});
if ~ok, error(mess), end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
