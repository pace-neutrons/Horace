function varargout = ds2(w,varargin)
% Draw a surface plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> ds2(w)       % Use error bars to set colour scale
%   >> ds2(w,wc)    % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%   >> ds2(...,xlo,xhi)
%   >> ds2(...,xlo,xhi,ylo,yhi)
%   >> ds2(...,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Differs from ds in that the signal sets the z axis, and the colouring is
% set by the error bars, or by another object. This enables two related 
% functions to be plotted (e.g. dispersion relation where the 'signal'
% array holds the energy and the error array holds the spectral weight).
%
% Advanced use:
%   >> ds2(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ds2(...)

opt=struct('newplot',true,'lims_type','xyz');
[fig_,axes_,plot_] = plot_2d_nd_oc_(w,nargout,'surface2',opt,varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end