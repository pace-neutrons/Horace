function varargout = sliceomatic_overview (w, varargin)
% Plots an IX_dataset_3d object using sliceomatic viewed straight down one of the axes
% When the slider for that axis is moved we get a series of what appear to be
% two-dimensioonal slices.
%
%   >> sliceomatic_overview (w)         % down the third (i.e. vertical) axis
%   >> sliceomatic_overview (w, axis)   % down the axis of choice (axis=1,2 or 3)
%
% Captions on axis slider bars (captions are character strings):
%   >> sliceomatic_overview (w, ..., 'x_axis', xcaption, ...)
%   >> sliceomatic_overview (w, ..., 'y_axis', ycaption, ...)
%   >> sliceomatic_overview (w, ..., 'z_axis', zcaption, ...)
%
% To enable isonormals:
%   >> sliceomatic_overview (w,... 'isonormals', true)
%
% Advanced use:
%   >> sliceomatic_overview (w, ..., 'name', fig_name, ...)
%                                               % draw with name = fig_name
%
% Return figure and axes handles, and a structure with plot data:
%   >> [fig_handle, axes_handle, plot_data] = sliceomatic_overview (w, ...)
%
%
% NOTES:
%
% - Ensure that the slice colour plotting is in 'texture' mode -
%      On the 'AllSlices' menu click 'Colour Texture'. No indication will
%      be made on this menu to show that it has been selected, but you can
%      see the result if you right-click on an arrow indicating a slice on
%      the graphics window.
%
% - To set the default for future Sliceomatic sessions -
%      On the 'Object_Defaults' menu select 'Slice Colour Texture'


% Check input arguments
% ---------------------
% Perform the checks that are specific to sliceomatic_overviw, and let the call
% to sliceomatic look after the checking of all the other arguments.
if numel(w)~=1
    error('HERBERT:IX_dataset_3d:invalid_argument', ...
        'Sliceomatic only works for a single 3D dataset, not an array of datasets')
end

% Check arguments for the axis index
if numel(varargin)>=1 && isscalar(varargin{1}) && isnumeric(varargin{1})
    if any(varargin{1}==[1,2,3])
        iax = varargin{1};
        arg_start = 2;      % index of start of remaining arguments
    else
        error('HORACE:d3d:invalid_argument', ...
            'Axis argument must be an integer in the range 1 to 3');
    end
else
    iax = 3;
    arg_start = 1;
end


% Perform the plot
% ----------------
varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = sliceomatic(w, varargin{arg_start:end});

% Set the camera position to view along the relevant axis
% Note that in the case of viewing down the y-axis the viewing position should
% be at a negative position along the y axis with respect to the box centroid in
% order to see the x-axis lower limit at the left and upper limit at the right.
lims = axis();
box_centroid = (lims(1:2:5) + lims(2:2:6)) / 2;    % centre of the plot box
side_lengths = lims(2:2:6) - lims(1:2:5);
if iax==1
    camera_pos = box_centroid + [side_lengths(1), 0, 0];
elseif iax==2
    camera_pos = box_centroid + [0, -side_lengths(2), 0];    % view from -ve y
elseif iax==3
    camera_pos = box_centroid + [0, 0, side_lengths(3)];
end

set(gca, 'CameraTarget', box_centroid, 'CameraPosition', camera_pos);
