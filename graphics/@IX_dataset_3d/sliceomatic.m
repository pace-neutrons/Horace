function [fig_handle, axes_handle, plot_handle] = sliceomatic(w, varargin)
% Plots IX_dataset_3d object using sliceomatic
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

%   function parse_test (varargin)
%   % 
%   arglist = struct('background',[12000,18000], ...    % argument names and default values
%                    'normalise', 1, ...
%                    'modulation', 0, ...
%                    'output', 'data.txt');
%   flags = {'normalise','modulation'};                 % arguments which are logical flags
%   
%   [par,argout,present] = parse_arguments(varargin,arglist,flags);
%   par
%   argout
%   present

arglist=struct('isonormals',0);
flags={'isonormals'};

[par,opt,present] = parse_arguments(varargin,arglist,flags);
if ~isempty(par)
    error('Check arguments')
end

if numel(w)~=1
    error('sliceomatic only works for a single 3D dataset')
end

[xlabel,ylabel,zlabel,slabel]=make_label(w);
clim = [min(w.signal(:)) max(w.signal(:))];

sz=size(w.signal);
if numel(w.x)~=sz(1)
    ux=[0.5*(w.x(2)+w.x(1)), 0.5*(w.x(end)+w.x(end-1))];
else
    ux=[w.x(1),w.x(end)];
end
if numel(w.y)~=sz(2)
    uy=[0.5*(w.y(2)+w.y(1)), 0.5*(w.y(end)+w.y(end-1))];
else
    uy=[w.y(1),w.y(end)];
end
if numel(w.z)~=sz(3)
    uz=[0.5*(w.z(2)+w.z(1)), 0.5*(w.z(end)+w.z(end-1))];
else
    uz=[w.z(1),w.z(end)];
end

% Plot data
sliceomatic(ux,uy,uz,w.signal,'x-axis','y-axis','z-axis',xlabel,ylabel,zlabel,clim,opt.isonormals);
title(w.title);
[fig_, axes_, plot_, plot_type] = genie_figure_all_handles (gcf);

% Resize the box containing the data
% set(gca,'Position',[0.225,0.225,0.55,0.55]);
set(gca,'Position',[0.2,0.2,0.6,0.6]);
axis normal

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
