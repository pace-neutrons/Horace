function [fig_handle, axes_handle, plot_handle] = mplot(w,varargin)
% Draw an area plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> mplot(w)
%   >> mplot(w,xlo,xhi)
%   >> mplot(w,xlo,xhi,ylo,yhi)
%   >> mplot(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> mplot(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = mplot(w,...) 
%
%
% Synonym for:
%   >> da(...)


% Check input arguments
opt=struct('newplot',true,'lims_type','xyz');
[args,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});

% Perform plot
type='area';
[fig_,axes_,plot_]=plot_twod (w,opt.newplot,type,fig,lims{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
