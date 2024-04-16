function varargout = plot_1d_nd_(w,type,varargin)
%plot_1d_nd_ Plot one or array of 1D datasets on separate plots
%
%
% Inputs:
% w     -- one or array of 1D datasets
%          have.
% type  -- type of plot to perform. See calling routines for details
% varargin
%       -- additional parameters calling routine may request. See calling
%          routine for details of this parameters
%
% Returns:
% fig_   -- array or cellarray with handles to the plotted figures
% axes_  -- array or cellarray of handles for axis of each figure
% plot_  -- array or cellarray of handles for plots placed on each figure



% check input arguments
opt=struct('newplot',true,'lims_type','xy');
[~,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});


% perform plot
[fig_,axes_,plot_]=plot_oned (w,opt.newplot,type,fig,lims{:});


% if output requested, combine output in array of graphical objects
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
