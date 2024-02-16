function varargout = da(w,varargin)
% Draw an area plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> da(w)
%   >> da(w,xlo,xhi)
%   >> da(w,xlo,xhi,ylo,yhi)
%   >> da(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> da(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = da(w,...)


% Check input arguments
opt=struct('newplot',true,'lims_type','xyz');
[~,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});

% Perform plot
type='area';
[fig_,axes_,plot_]=plot_twod (w,opt.newplot,type,fig,lims{:});


% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
