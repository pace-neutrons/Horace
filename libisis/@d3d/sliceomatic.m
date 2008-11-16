function sliceomatic(win, varargin)
% Plots d3d object using sliceomatic
%
% Syntax:
%   >> sliceomatic (win)
%   >> sliceomatic (win, 'isonormals', true)     % to enable isonormals
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

sliceomatic(sqw(win),varargin{:});