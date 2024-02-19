function varargout = ds(w,varargin)
% Draw a surface plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> ds(w)
%   >> ds(w,xlo,xhi)
%   >> ds(w,xlo,xhi,ylo,yhi)
%   >> ds(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> ds(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ds(w,...) 

opt=struct('newplot',true,'lims_type','xyz');
[fig_,axes_,plot_] = plot_2d_nd_(w,nargout,'surface',opt,varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
