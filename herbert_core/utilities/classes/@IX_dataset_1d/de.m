function varargout = de(w,varargin)
% Draws a plot of error bars of a spectrum or array of spectra
%
%   >> de(w)
%   >> de(w,xlo,xhi)
%   >> de(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> de(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = de(w,...) 


% Check input arguments
opt=struct('newplot',true,'lims_type','xy');
[args,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});

% Perform plot
type='e';
[fig_,axes_,plot_]=plot_oned (w,opt.newplot,type,fig,lims{:});

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
