function varargout = sliceomatic(w, varargin)
% Plots IX_dataset_3d object using sliceomatic
%
%   >> sliceomatic (w)
%   >> sliceomatic (w, 'isonormals', true)      % to enable isonormals
%
% Control tabs on axis slider bars:
%   >> sliceomatic (w,..., 'x_axis',xtab,...)   % xtab is a character string label
%                                               % (and similarly for y_axis, z_axis)
%
% Advanced use:
%   >> sliceomatic (w,..., 'name',fig_name)     % draw with name = fig_name
%
% Return figure, axes and plot handles:
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

arglist=struct('name','',...
    'x_axis','x-axis',...
    'y_axis','y-axis',...
    'z_axis','z-axis',...
    'isonormals',0);
flags={'isonormals'};

[par,keyword,present] = parse_arguments(varargin,arglist,flags);

% Check input arguments
% ---------------------
if ~isempty(par)
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'Invalid sliceomatic arguments:\n %s',disp2str(par))
end

if numel(w)~=1
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'Sliceomatic only works for a single 3D dataset')
end

% Get figure name: if not given, use appropriate default sliceomatic plot name
if is_string(keyword.name)
    if ~isempty(keyword.name)
        fig_name=keyword.name;
    else
        fig_name=get_global_var('genieplot','name_sliceomatic');
    end
else
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'Figure name must be a character string')
end

% Plot data
% ----------
% Prepare arguments for call to sliceomatic
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

% Permute axes 1 and 2 - usual wierd Matlab thing
signal = permute(w.signal,[2,1,3]);

[xlabel,ylabel,zlabel]=make_label(w);
clim = [min(w.signal(:)) max(w.signal(:))];
if clim(2) == clim(1)
    clim(1) = clim(1)-1;
    clim(2) = clim(2)+1;
end

% ------ Fixes problem on dual monitor systems. Need checks about negative side
% effects on other systems.
mode = get(0, 'DefaultFigureRendererMode');
rend = get(0, 'DefaultFigureRenderer');
set(0, 'DefaultFigureRendererMode', 'manual');
set(0,'DefaultFigureRenderer','zbuffer');
% ------

% Plot data
plot_ = sliceomatic(ux, uy, uz, signal, keyword.x_axis, keyword.y_axis, keyword.z_axis,...
    xlabel, ylabel, zlabel, clim, keyword.isonormals,fig_name);

% ----- Return rendering mode
set(0, 'DefaultFigureRendererMode', mode);
set(0,'DefaultFigureRenderer',rend );
% ------

%title(w.title,'FontWeight','normal','FontSize',10);
title(w.title,'FontWeight','normal');
[fig_, axes_] = genie_figure_all_handles (gcf);

% Because we are not going through the usual genie_figure_create route, set some of
% the options that function sets
set(fig_,'Name',fig_name,'Tag','','PaperPositionMode','auto','Color','white');

% Resize the box containing the data
% set(gca,'Position',[0.225,0.225,0.55,0.55]);
set(gca,'Position',[0.2,0.2,0.6,0.6]);
axis normal

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
