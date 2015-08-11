function [figureHandle, axesHandle, plotHandle] = sliceomatic(w, varargin)
% Plots 3D sqw object using sliceomatic
%
%   >> sliceomatic (w)
%   >> sliceomatic (w, 'isonormals', true)     % to enable isonormals
%
%   >> sliceomatic (w,...,'-noaspect')  % Do not change aspect ratio
%                                       % according to data axes unit lengths
%
% To get handles to the graphics figure:
%   >> [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(w,...)
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

% Dean Whittaker 2008
% T.G.Perring 13 Nov 2008

if numel(w)~=1
    error('sliceomatic only works for a single 3D dataset')
end
if dimensions(w)~=3
    error('sliceomatic only works for 3D datasets');
end

% Strip trailing option, if present
[ok,mess,opt_adjust,opt_present]=adjust_aspect_option(varargin);
if ~ok, error(mess), end

pax = w.data.pax;
dax = w.data.dax;                 % permutation of projection axes to give display axes
ulabel = w.data.ulabel(pax(dax)); % labels in order of the display axes
ulen = w.data.ulen(pax(dax));     % unit length in order of the display axes

% Create sliceomatic window
name_sliceomatic =  get_global_var('horace_plot','name_sliceomatic');
[figureHandle_, axesHandle_, plotHandle_] = sliceomatic (IX_dataset_3d(w),'x_axis',ulabel{1},'y_axis',ulabel{2},'z_axis',ulabel{3},...
    'name',name_sliceomatic,varargin{1:end-opt_present});

% Rescale plot so that aspect ratios reflect relative lengths of Q axes
if adjust_aspect(w) && opt_adjust
    energy_axis = 4;    % by convention, the energy axis is always the 4th projection axis
    if isempty(find(pax==energy_axis, 1))   % none of the plot axes is an energy axis
        aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
    else
        aspect = [1/ulen(1), 1/ulen(2), 1/ulen(3)];
        a = get(gca,'DataAspectRatio');
        epax = find(pax(dax)==energy_axis); % index of the display axis corresponding to energy
        qpax = rem([epax,epax+1],3)+1;      % indices of the other two display axes (cyclic permutation)
        aspect(epax) = a(epax)/max([ulen(qpax(1))*a(qpax(1)), ulen(qpax(2))*a(qpax(2))]);
    end
    set(gca,'DataAspectRatio',aspect);
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
