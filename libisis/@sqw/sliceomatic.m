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

% T.G.Perring 13 Nov 2008:
%
% Dean's code in his libisis Horace conversion contained:
% sm(w, 'clim', clim, 'title', title_iax{1}, 'xlabel', title_pax{1}, 'ylabel', title_pax{2}, ...
%      'zlabel', title_pax{3}, 'x_sliderlabel', ['axis 1: ',label{pax(1)}], ...
%      'y_sliderlabel', ['axis 2: ',label{pax(2)}],  'z_sliderlabel', ['axis 3: ',label{pax(3)}],  ...
%      'aposition', [0.225,0.225,0.55,0.55], varargin{:});
%
% However, I find that in general there are problems:
% (1) When using while title, xlabel and ylabel can be omitted and
%     these will be constructed from the IXTdataset_3D object, but 
%     the z-axis label is set to the title of the dataset3d
% (2) Slider labels *must* be given - that is, there is no dedefault.
% (3) 'clim' must be given
% (4) The 'aposition' argument doesn't seem to do anything.
% (5) lx, ly, lz do not work with sliceomatic


if numel(win)~=1
    error('sliceomatic only orks for a single 3D dataset')
end
if dimensions(win)~=3
    error('sliceomatic only works for 3D datasets');
end

w = IXTdataset_3d(win);

pax = win.data.pax;
dax = win.data.dax;                 % permutation of projection axes to give display axes
ulabel = win.data.ulabel(pax(dax)); % labels in order of the display axes
ulen = win.data.ulen(pax(dax));     % unit length in order of the display axes

clim = [min(w.signal(:)) max(w.signal(:))];
[title_main, title_pax] = plot_titles (win);    % note: axes annotations correctly account for permutation in w.data.dax
[figureHandle_, axesHandle_, plotHandle_]=sm(w, 'clim', clim, ...
    'title', title_main, 'xlabel', title_pax{1}, 'ylabel', title_pax{2}, 'zlabel', title_pax{3},...
    'x_sliderlabel', ['axis 1: ',ulabel{1}], 'y_sliderlabel', ['axis 2: ',ulabel{2}],  'z_sliderlabel', ['axis 3: ',ulabel{3}],...
    varargin{:});

% Resize the box containing the data
% set(gca,'Position',[0.225,0.225,0.55,0.55]);
set(gca,'Position',[0.2,0.2,0.6,0.6]);
axis normal

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
