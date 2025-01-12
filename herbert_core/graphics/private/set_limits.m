function varargout = set_limits (axName, varargin)
% Service function called by the Herbert graphics routines lx, ly, lz, and lc to
% set limits along one of tbe x, y, z and color axes on the current axes of the
% current figure:
%
%   >> [...] = set_limits (axName, ...)
%
% Here, axName is the axis to be changed: 'X', 'Y', 'Z', 'C' for tbe x, y, z and
% color axes respectively.
%
% If there is no z-axis in the current axes, but there is colour data, it is
% assumed that the limits are to be set for colour data range. This is what is
% expeted if the Matlab function called patch has been used to create area
% plots.
%
% This service routine has the following functionality:
%
% Replot with change of limits:
%   >> set_limits (axName, xlo, xhi)    % Sets limits to xlo to xhi; the limits
%                                       % retained for further overplotting
%
% Change limits to autoscale to encompass all data:
%   >> set_limits (axName)              % Set limits to match the range of the
%                                       % data. The limits automatically change
%                                       % to accommodate  further overplotting
%
%   The default automatic limit method is to exactly match the range of the data.
%   Automatic limits can be set and the default behaviour altered for all
%   subsequent overplotting to the current figure withone of the options:
%
%   >> set_limits (axName, 'padded')    % Add a thin margin of padding each side
%                                       % of the full data range
%   >> set_limits (axName, 'rounded')   % Equivalent syntax
%   >> set_limits (axName, 'tickaligned') % Align to tick marks while still
%                                       % encompassing the full data range
%   >> set_limits (axName, 'tight')     % [Default] Fit the limits to tightly
%                                       % match the full data range
%       :
%
% Return current limits (without changing range):
%   >> [xlo, xhi] = set_limits (axName)
%
%   Note that if the limits have been set to autoscale, then the return values
%   are [-Inf, Inf]
%
% Replot several times with different limits in sequence:
%   (Change limits to first pair [xlo(1),xhi(1)], then hit <CR> to change to the
%   next pair in then sequence, [xlo(2),xhi(2)], and so on)
%   >> set_limits (axName, xlo, xhi)    % xlo and xhi are arrays with the same
%                                       % number of elements;
%
%   or, for backwards compatibility:
%   >> set_limits (axName, [xlo1,xhi2], [xlo2,xhi2],...)    % xlo1, xhi1, slo2,
%                                                           % xhi2... scalars
%   >> set_limits (axName, {[xlo1,xhi2],[xlo2,xhi2],...})   % equivalent syntax
%
%
% This function closely mimics the matlab intrinsic functions xlim, ylim, zlim


narg = numel(varargin);     % number of optional arguments

LimitMethod_opt = {'padded','rounded','tickaligned','tight'};
LimitMethod = {'padded','padded','tickaligned','tight'};

% Check there is a current figure
% Query without creating a figure if there is no current figure
fig = get(groot,'CurrentFigure');
if isempty(fig)
    warning('No current figure - change limits ignored')
    return
end

% Check there are axes (without creating axes if there are none)
ax = fig.CurrentAxes;
if isempty(ax)
    warning('No axes on current figure - change limits ignored')
    return
end

% Determine if there is a z-axis
% ------------------------------
if strcmpi(axName, 'Z') && numel(axis)/2 ~= 3
    % The function has been requested to operate on the z-axis, but there is no
    % z-axis. Assume that the operation is to be applied to colour data instead,
    % if there is any.
    % (Note: the Matlab function axis returns the lower an upper limits of the
    % plot axes; length(axis)==4 if x and y axes only, and ==6 is z-axis too)
    axPresent = data_present (ax);   % data axis presence on current axes
    if ~axPresent.c
        error('HERBERT:graphics:invalid_argument', ['No z-axis or colour ', ...
            'data on the current figure and axes - change limits ignored']);
    end
    axName = 'C';
    
elseif strcmpi(axName, 'C')
    % The function has been requested to operate on the colour scale. Check
    % there is colour data present
    axPresent = data_present (ax);   % data axis presence on current axes
    if ~axPresent.c
        error('HERBERT:graphics:invalid_argument', ['No colour ', ...
            'data on the current figure and axes - change limits ignored']);
    end
end


% Return plot limits, if requested
% --------------------------------
if nargout>0
    % It is an error of the function syntax to return the current plot limits if
    % there is an attempt to alter the plot limits
    if narg>0
        error('HERBERT:graphics:invalid_argument', ['It is an error to ', ...
            'return the current limits if there are input arguments too']);
    end
    % Get current graph limits
    lims = get(gca, [axName,'Lim']);
    if nargout>=1
        varargout{1} = lims(1);
    end
    if nargout>=2
        varargout{2} = lims(2);
    end
    return
end


% Set x-axis plot limits
% ----------------------
% If we got this far, then there is a request to alter the plot limits.

% Case of change limits to the full range of the data, optionally setting the
% padding option at the same time.
if narg==0 || (narg==1 && ~isempty(varargin{1}) && is_string(varargin{1}))
    % Change the limits method before changing the limits mode to 'auto'
    % so that the relevant padding option 'tight',' padded' etc. (either already
    % set, or passed as the input argument) is activated beforehand.
    if narg==1
        % Check optional limit method
        ind = stringmatchi(varargin{1}, LimitMethod_opt);
        if numel(ind)~=1
            error('HERBERT:graphics:invalid_argument', ['Check the validity ', ...
                'and uniqueness of the automatic limit method option']);
        end
        % The autoscaling control options do not apply to colour data - there is
        % no property called CLimitMethod - so print an information message
        if strcmpi(axName, 'C')
            disp('Limits padding options do not apply here. Autoscaling to the data range.')
        end
        set(gca, [axName,'LimitMethod'], LimitMethod{ind});
    end
    % Sets limit mode to 'auto', so further plotting to the same figure results
    % in expansion of the axis range if needed to display the additional data
    set(gca, [axName,'LimMode'], 'auto');
    return
end

% Cases of explicitly setting the limits, and freezing them for subsequent
% overplotting to the current plot.
if narg==2
    % Check we have two non-empty numeric vectors with the same length
    if ~isnumeric(varargin{1}) || ~isnumeric(varargin{2}) || ...
            isempty(varargin{1}) || numel(varargin{1})~=numel(varargin{2})
        error('HERBERT:graphics:invalid_argument', ['Check the input ', ...
            'arguments are two numeric scalars']);
    else
        range = [double(varargin{1}(:)), double(varargin{2}(:))]; % 1x2 array
    end
elseif narg==1 && iscell(varargin{1})
    % Check argument is a cell array of numeric pairs
    numeric_pair = @(x)(isnumeric(x) && numel(x)==2);
    if isempty(varargin{1}) || ~all(cellfun(numeric_pair, varargin{1}))
        error('HERBERT:graphics:invalid_argument', ['Cell array input ', ...
            'argument must contain numeric pairs only']);
    else
        % Turn into a cell array of column vectors, then combine into an Nx2 array
        tmp = cellfun(@make_column, varargin{1}, 'UniformOutput', false);
        range = cell2mat(tmp)';
    end
else
    % Check that the arguments are all numeric pairs
    numeric_pair = @(x)(isnumeric(x) && numel(x)==2);
    if ~all(cellfun(numeric_pair, varargin))
        error('HERBERT:graphics:invalid_argument', ['Input argument(s)', ...
            'must all be numeric pairs only']);
    else
        % Turn into a cell array of column vectors, then combine into an Nx2 array
        tmp = cellfun(@make_column, varargin, 'UniformOutput', false);
        range = cell2mat(tmp)';
    end
end

% Check range has a non-zero width
% Note that one or both of range(i,1) = -Inf and range(i,2) = Inf is acceptable,
% where i is the index of once of the ranges.
% The result is that the limits are set to the full range of the data. This
% is consistent with Matlab intrinsic behaviour of xlim, ylim, zlim functions.
if any(range(:,1) >= range(:,2) | isnan(range(:,1)) | isnan(range(:,2)))
    error('HERBERT:graphics:invalid_argument', ['Check the input ', ...
        'arguments: the lower limit must be less than the higher']);
end

% Set limits
nrange = size(range,1);
for i=1:nrange
    set(gca, [axName,'Lim'], range(i,:));
    if i~=nrange
        input('hit <CR> to continue')
    end
end

%-------------------------------------------------------------------------------
function present = data_present(axes_handle)
% Determine which of x,y,z and color data exist in a figure on a set of axes
%
%   >> present = data_present(axes_handle)
%
% Input:
% ------
%   fig_handle  Axes handle
%
% Output:
% -------
%   present     Structure with fields each containing a logical scalar:
%                   x   XData present
%                   y   YData present
%                   z   ZData present
%                   c   CData present


% Get handles of all objects with XData
xdata_h = findobj(axes_handle, '-property', 'XData');

% Get the XData and YData for those objects (note that every object that has
% XData also has YData)
xdata_cell = get(xdata_h, 'XData');
ydata_cell = get(xdata_h, 'YData');

% While every object that has XData also has YData, not all of those objects
% will have Zdata or CData.
zdata_cell = cell(size(xdata_cell));
cdata_cell = cell(size(xdata_cell));
for i = 1:numel(xdata_cell)
    try
        zdata_cell{i} = get(xdata_h(i), 'ZData');
    end
    try
        cdata_cell{i} = get(xdata_h(i), 'CData');
    end
end

present.x = ~all(cellfun(@isempty, xdata_cell));
present.y = ~all(cellfun(@isempty, ydata_cell));
present.z = ~all(cellfun(@isempty, zdata_cell));
present.c = ~all(cellfun(@isempty, cdata_cell));
