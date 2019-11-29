function [fig_handle, axes_handle, plot_handle] = ds2(w,varargin)
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


% Check input arguments (must allow for the two cases of one or two plotting input arguments)
if ~isa(w,'IX_dataset_2d')
    error('First argument must be a 2D data object class IX_dataset_2d')
end

opt=struct('newplot',true,'lims_type','xyz');
[args,ok,mess,nw,lims,fig]=genie_figure_parse_plot_args2(opt,w,varargin{:});
if ~ok, error(mess), end
if nw==2
    data={w,IX_dataset_2d(varargin{1})};
else
    data=w;
end

% Perform plot
type='surface2';
[fig_,axes_,plot_,ok,mess]=plot_twod (data,opt.newplot,type,fig,lims{:});
if ~ok, error(mess), end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
