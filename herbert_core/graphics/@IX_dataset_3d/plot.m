function [fig_handle, axes_handle, plot_handle] = plot(w, varargin)
% Plots IX_dataset_3d object using sliceomatic
%
%   >> plot (w)
%   >> plot (w, 'isonormals', true)      % to enable isonormals
%
% Control tabs on axis slider bars:
%   >> plot (w,..., 'x_axis',xtab,...)   % xtab is a character string label
%                                               % (and similarly for y_axis, z_axis)
%
% Advanced use:
%   >> plot (w,..., 'name',fig_name)     % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [figureHandle_, axesHandle_, plotHandle_] = plot(w,...)
%
% Synonym for >> sliceomatic(...)
%
%
% NOTES:
%
% - Ensure that the slice color plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Color Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions - 
%      On the 'Object_Defaults' menu select 'Slice Color Texture'


% Call sliceomatic
[fig_, axes_, plot_] = sliceomatic(w, varargin{:});

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
