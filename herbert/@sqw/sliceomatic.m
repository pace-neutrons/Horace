function [figureHandle, axesHandle, plotHandle] = sliceomatic(win, varargin)
% Plots 3D sqw object using sliceomatic
%
%   >> sliceomatic (win)
%   >> sliceomatic (win, 'isonormals', true)     % to enable isonormals
%
% To get handles to the graphics figure:
%   >> [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(win)
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

if numel(win)~=1
    error('sliceomatic only works for a single 3D dataset')
end
if dimensions(win)~=3
    error('sliceomatic only works for 3D datasets');
end

w = IX_dataset_3d(win);

pax = win.data.pax;
dax = win.data.dax;                 % permutation of projection axes to give display axes
ulabel = win.data.ulabel(pax(dax)); % labels in order of the display axes
ulen = win.data.ulen(pax(dax));     % unit length in order of the display axes

% Create sliceomatic window

if get(hor_config,'use_her_graph')
    name_sliceomatic= get(graph_config,'name_sliceomatic');
else
    name_sliceomatic =  get_global_var('horace_plot','name_sliceomatic');	
end

[figureHandle_, axesHandle_, plotHandle_] = sliceomatic (w,'x_axis',ulabel{1},'y_axis',ulabel{1},'z_axis',ulabel{1},...
                                                            'name',name_sliceomatic,varargin{:});

% Rescale plot so that aspect ratios reflect relative lengths of Q axes
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

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
