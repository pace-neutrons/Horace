function [fig_handle, axes_handle, plot_handle] = ps2(w,varargin)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> ps2(w)       % Use error bars to set colour scale
%   >> ps2(w,wc)    % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%
% Advanced use:
%   >> ps2(...,'name',fig_name)     % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Differs from ps in that the signal sets the z axis, and the colouring is set by the 
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...) 


% Check input arguments (must allow for the two cases of one or two plotting input arguments)
if ~isa(w,'IX_dataset_2d')
    error('First argument must be a 2D data object class IX_dataset_2d')
end

opt=struct('newplot',false);
[args,ok,mess,nw,lims,fig]=genie_figure_parse_plot_args2(opt,w,varargin{:});
if ~ok, error(mess), end
if nw==2
    data={w,IX_dataset_2d(varargin{1})};
else
    data=w;
end

% Perform plot
type='surface2';
[fig_,axes_,plot_,ok,mess]=plot_twod (data,opt.newplot,type,fig);
if ~ok, error(mess), end

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
