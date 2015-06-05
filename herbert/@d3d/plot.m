function [figureHandle, axesHandle, plotHandle] = plot(w, varargin)
% Plots d3d object using sliceomatic
%
% Syntax:
%   >> plot (w)
%   >> plot (w, 'isonormals', true)     % to enable isonormals
%
% Equivalent to
%   >> sliceomatic (w,...)
%
%
% NOTES:
%
% - Ensure that the slice color plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Color Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics wdow.
%
% - To set the default for future Sliceomatic sessions - 
%      On the 'Object_Defaults' menu select 'Slice Color Texture'

[figureHandle_, axesHandle_, plotHandle_] = sliceomatic(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
if ~verLessThan('matlab','8.4')
   figure(figureHandle_)
end
