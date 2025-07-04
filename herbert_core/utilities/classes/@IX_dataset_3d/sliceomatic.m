function varargout = sliceomatic (w, varargin)
% Plots an IX_dataset_3d object using sliceomatic
%
%   >> sliceomatic (w)
%
% Captions on axis slider bars (captions are character strings):
%   >> sliceomatic (w, ..., 'x_axis', xcaption, ...)
%   >> sliceomatic (w, ..., 'y_axis', ycaption, ...)
%   >> sliceomatic (w, ..., 'z_axis', zcaption, ...)
%
% To enable isonormals:
%   >> sliceomatic (w, ..., 'isonormals', true, ...)      
%
% Advanced use:
%   >> sliceomatic (w, ..., 'name', fig_name, ...)   % draw with name = fig_name
%
% Return figure and axes handles, and a structure with plot data:
%   >> [fig_handle, axes_handle, plot_data] = sliceomatic (w, ...)
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


% Check input arguments
% ---------------------
arglist=struct('name','Sliceomatic',...
    'x_axis','x-axis',...
    'y_axis','y-axis',...
    'z_axis','z-axis',...
    'isonormals',0);
flags={'isonormals'};
[par,keyword] = parse_arguments(varargin,arglist,flags);

if ~isempty(par)
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'Invalid sliceomatic arguments given:\n %s',disp2str(par,80))
end

if numel(w)~=1
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'Sliceomatic only works for a single 3D dataset, not an array of datasets')
end


% Prepare arguments for call to sliceomatic
% -----------------------------------------
% Sliceomatic only handles the case of equally spaced points, and need at least
% two points along each axis
sz=size(w.signal);
if any(sz==0)
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'There is no data in the signal array')
end

% Set data ranges
point_data = ~ishistogram(w);
reltol = 1e-4;  % relaxed tolerance on equal spacing as only plotting
[ux, xuniform] = check_axis_values (w.x, point_data(1), reltol);
[uy, yuniform] = check_axis_values (w.y, point_data(2), reltol);
[uz, zuniform] = check_axis_values (w.z, point_data(3), reltol);
if ~xuniform || ~yuniform || ~zuniform
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'Data points must be equally spaced for sliceomatic.')
end

% Permute axes 1 and 2 - usual weird Matlab thing
signal = permute(w.signal,[2,1,3]);

% Main plot axis annotations
[tx, ty ,tz] = make_label(w);
clim = [min(w.signal(:)) max(w.signal(:))];
if clim(2) == clim(1)
    clim(1) = clim(1)-1;
    clim(2) = clim(2)+1;
end

% Captions to axis slider bars
xcaption = keyword.x_axis;
ycaption = keyword.y_axis;
zcaption = keyword.z_axis;


% Set the plot target figure
% --------------------------
% Change the default figure size to be 50% bigger, as sliceomatic is a busy
% figure. Then after creating the figure, if needed, return to the original
% default.
% As changing the default position affects the entire matlab session (and here
% will increase the size by 50% everytime one breaks a debug session while in
% genie_figure_set_target), make a cleanup object to recover the default on exit
default_position = get(groot, 'DefaultFigurePosition');
cleanup = onCleanup(@()set(groot, 'DefaultFigurePosition', default_position));

set(groot, 'DefaultFigurePosition', [100, 100, round((3*default_position(3:4))/2)])
genie_figure_set_target (keyword.name); % sets the target as the current figure
set(groot, 'DefaultFigurePosition', default_position)


% Plot data
% ---------
fig_name = get(gcf, 'Name');
plot_data = sliceomatic(ux, uy, uz, signal, xcaption, ycaption, zcaption, ...
    tx, ty, tz, clim, keyword.isonormals, fig_name);

% Return the figure to being a genie_figure.
% Sliceomatic resets the figure window which removes the 'keep' / 'make current'
% menu items and resets all the figure properties.
genie_figure_create(gcf, fig_name)

% Resize the box containing the data
set(gca, 'Position', [0.2, 0.2, 0.6, 0.6]); 
axis normal

% Set the title
tt = w(1).title(:);
if any(contains(tt, '$'))
    inter = 'latex';
else
    inter = 'tex';
end
title(tt, 'FontWeight', 'normal', 'interpreter', inter);

% Output only if requested
varargout = cell(1, min(3,nargout));
[varargout{:}] = genie_figure_all_handles (gcf);
if nargout>=3
    varargout{3} = plot_data;
end


%-------------------------------------------------------------------------------
function [ux, uniform] = check_axis_values (x, point_data, reltol)
% Check abscissae are equally spaced and return the lower and upper values.
%
%   >> [ux, uniform] = check_axis_values (x, point_data, reltol)
%
% Sliceomatic requires equally spaced abscissae with non-zero separation of the
% data points along an axis.
%
% Input:
% ------
%   x           Abscissae (vector). Must have numel(x)>=1 if point data or
%               numel(x)>2 if not point data.
%
%   point_data  True if point data, false if histogram data.
%
%   reltol      Relative tolerance for checking absiccae are equally spaced.
%               Tolerance is with respect to the deviation from the mean spacing
%               of the abscissae.
%
% Output:
% -------
%   ux          Lower and upper abscissae (row vector).
%               If point data with just one point, return [x-0.5, x+0.5].
%               If histogram data with just one point, return x.
% 
%   uniform     True: equally spaced abscissae with non-zero separation within
%                     the given tolerance.
%               False: not equally spaced or at least two equal values.

% Check validity of 
if isempty(x) || (isscalar(x) && ~point_data)
    error('HERBERT:IX_dataset_3d:invalid_argument', ['Must have at least ' ...
        'one abscissa (point data) or two abscissae (histogram data)'])
end

% Check absciccae are equally spaced
uniform = true;
if numel(x)>1
    dx_ref = (x(end)-x(1))/(numel(x)-1);
    dx = diff(x);
    reldiff = (dx-dx_ref)/dx_ref;
    if dx_ref==0 || any(dx<0) || ~all(isfinite(reldiff)) || ...
            any(abs(reldiff)>abs(reltol))
        uniform = false;
    end
end

% Get extremal abscissae
if ~point_data
    if numel(x)>2
        ux = [0.5*(x(2)+x(1)), 0.5*(x(end)+x(end-1))];
    else
        ux = [x(1), x(end)];    % only one data point
    end    
else
    if numel(x)>1
        ux = [x(1), x(end)];
    else
        ux = [x-0.5, x+0.5];    % non-zero width if plotting one data point
    end
end
