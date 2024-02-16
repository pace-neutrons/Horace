function varargout = pp(w,varargin)
% Overplot markers and error bars for a spectrum or array of spectra on an existing plot
%
%   >> pp(w)
%
% Advanced use:
%   >> pp(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pp(w,...)


% Check input arguments
opt=struct('newplot',false);
[args,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});

% Perform plot
type='p';
[fig_,axes_,plot_]=plot_oned (w,opt.newplot,type,fig);

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
