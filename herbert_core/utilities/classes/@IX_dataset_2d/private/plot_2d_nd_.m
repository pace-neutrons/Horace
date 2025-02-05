function [fig_,axes_,plot_] = plot_2d_nd_(w,nout,type,opt,varargin)
%plot_2d_nd_ Plot one or array of 2D datasets on separate plots
%
% Inputs:
% w     -- one or array of 2D datasets
% nout  -- number of output arguements requested by the calling routine
%          This defines the form output arguments of this routine will
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

% Check input arguments
[~,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});



% perform plot
[fig_,axes_,plot_]=plot_twod (w,opt.newplot,type,fig,lims{:});
% if output requested, combine output in array of graphical objects
