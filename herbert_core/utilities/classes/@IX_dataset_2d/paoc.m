function varargout = paoc(w)
% Overplot an area plot of an IX_dataset_2d or array of IX_dataset_2d on the current plot
%
%   >> paoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = paoc(w) 



opt=struct('newplot',false,'over_curr',true);
[fig_,axes_,plot_] = plot_2d_nd_(w,nargout,'area',opt);
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
