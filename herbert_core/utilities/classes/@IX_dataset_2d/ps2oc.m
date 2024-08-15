function varargout = ps2oc(w,varargin)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> psoc2(w)       % Use error bars to set colour scale
%   >> psoc2(w,wc)    % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%
% Differs from psoc in that the signal sets the z axis, and the colouring is set by the
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = psoc2(w)


opt=struct('newplot',false,'over_curr',true);
[fig_,axes_,plot_] = plot_2d_nd_oc_(w,nargout,'surface2',opt,varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
