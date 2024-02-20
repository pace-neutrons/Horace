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

opt=struct('newplot',true,'lims_type','xyz');
[fig_,axes_,plot_] = plot_2d_nd_(w,nargout,'area',opt,varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
