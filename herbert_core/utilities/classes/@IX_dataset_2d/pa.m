function varargout = pa(w,varargin)
% Overplot an area plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> pa(w)
%
% Advanced use:
%   >> pa(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pa(w,...) 


opt=struct('newplot',false);
[fig_,axes_,plot_] = plot_2d_nd_(w,nargout,'area',opt,varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
