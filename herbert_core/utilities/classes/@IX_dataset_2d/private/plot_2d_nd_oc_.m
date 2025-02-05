function [fig_,axes_,plot_] = plot_2d_nd_oc_(w,nout,type,opt,varargin)
%plot_2d_nd_oc_ Overplot one or array of 2D datasets on separate plots.
%               Use additional dataset if avaliable as the scaler to
%               provide axis scale.
%               Fails if first dataset to overplot is missing
%
% Inputs:
% w     -- one or array of 2D datasets or
%          cellarray containing one or array of 2D datasets and dataset-scaler
%          to draw axis scale
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
[~,nw,lims,fig]=genie_figure_parse_plot_args2(opt,w,varargin{:});
if nw==2
    scaler = IX_dataset_2d(varargin{1});
else
    scaler  = [];
end



% perform plot
if nw == 2
    [fig_,axes_,plot_]=plot_twod ({w,scaler},opt.newplot,type,fig,lims{:});
else
    [fig_,axes_,plot_]=plot_twod (w,opt.newplot,type,fig,lims{:});
end
