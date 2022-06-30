function [fig_handle, axes_handle, plot_handle] = ps2(w,varargin)
% This plotting function is not available for IX_dataset_1d objects.

disp('This plotting function is not available for IX_dataset_1d objects.')

% Output only if requested
if nargout>=1, fig_handle=-1; end
if nargout>=2, axes_handle=-1; end
if nargout>=3, plot_handle=-1; end
