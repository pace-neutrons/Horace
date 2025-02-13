function genie_figure_create (varargin)
% Create a genie_figure with a given name and status ('current' or 'keep').
%
% Create new genie_figure with a given name:
%   >> genie_figure_create (fig_name)
%   >> genie_figure_create (fig_name, status)       % set chosen status
%
% Convert an existing figure to a genie_figure, or update the name and status
% if it already is a genie_figure:
%   >> genie_figure_create (fig_handle)
%   >> genie_figure_create (fig_handle, fig_name)   % change name
%   >> genie_figure_create (..., status)            % set chosen status
%
%
% For details about genie_figures, see notes below.
%
% Input:
% ------
%   fig_handle  Existing figure: Handle to existing figure
%
%   fig_name    New figure: Name of genie_figure to be created  e.g. 'Genie 1D'.
%               Existing figure: Change name of window.
%               (Note: the empty string '' is a valid figure name)
%
%   status      Status with which to create the window: 'current' or 'keep'
%                - 'current': Becomes the 'current' status genie_figure of those
%                             with that name.
%                - 'keep':    Becomes a 'keep' status genie_figure of those with
%                             that name.
%
%               Default: 'current' status
%
% If a new figure with 'current' status is requested, then if there is already
% one with the requested name that has 'current' status that figure will be
% given 'keep' status.
%
%
%
% Notes about genie_figures
% -------------------------
% A 'genie_figure' is one which has the 'Keep' and 'Make Current' functionality.
% They are used by e.g. Horace, Herbert and the Matlab mslice applications to
% make the management of collections of related figures convenient. For example,
% Horace has one-dimensional plots, two-dimensional area plots, two-dimensional
% surface plots and 3D volume plots, and there can be several figures of each
% type. Only one of each set can be currently active for graphical output for
% the type accepted by that set; if none are (i.e. they all have 'keep' status),
% then a new figure of the appropriate type is created and set to 'current'
% status.
%
% More specificaly, the features of genie_figures are:
% - A name which can be shared by several figures to define a collection of
%  related figure windows (e.g. 'Horace 1D plot').
%
% - 'Keep' and 'Make Current' menus on the figure, whereby at most one of the
%  collection can be set to be the currently active one for further graphical
%  output directed to a genie_figure with that name.
%
% - Selecting one of the genie_figures to be have 'current' status (that is, to
%  be the currently active one in the collection) automatically sets the others
%  in the collection to 'keep' status.


% Technical details about genie_figures
% -------------------------------------
% A genie window will always have the following:
% - Property Tag with the value '<name>$current$' or '<name>$keep$', where
%   <name> is the value of the figure property Name (and which is the displayed
%   name of the plot following the figure number).
% - A uimenu with the tag 'make_cur' and one with tag 'keep'.
% - One of these uimenus will have property Enable set to 'on', the other will
%   have the property Enable set to 'off', according to the figure tag being
%   '<name>$current$' or '<name>$keep$'.
%
% To detect if a figure is a genie_figure the defining quality to be tested for
% is the presence of one of the tags '<name>$current$' and '<name>$keep$'. The
% presence of the uimenus alone is not sufficient as the visualisation
% application mslice also has those uimenus.


% Parse input arguments
% ---------------------
% Must start {handle}, {name}, or {handle, name}, with status as the optional
% final argument.
narg = numel(varargin);

% Read the value of the requested status, if given, else set default
if narg>0
    [ok, request_current] = is_argument_status (varargin{end});
    if ok
        narg = narg - 1;        % remove last argument from further parsing of input
    else
        request_current = true; % default
    end
end

% Check the reat of the input arguments
if narg==1 && (is_string(varargin{1}) || ...
        (isscalar(varargin{1}) && isgraphics(varargin{1}, 'figure')))
    if is_string(varargin{1})
        fig_handle = [];    % we will be creating the figure
        request_name = varargin{1};
    else
        fig_handle = varargin{1};
        request_name = get(fig_handle, 'Name');
    end
elseif narg==2 && is_string(varargin{2}) && ...
        (isscalar(varargin{1}) && isgraphics(varargin{1}, 'figure'))
    fig_handle = varargin{1};
    request_name = varargin{2};
else
    error('HERBERT:graphics:invalid_argument', ...
        ['Must provide a figure name, figure handle, or both in that order\n',...
        'optionally followed by status flag ''-current'' or ''-keep''.'])
end

% The convention for genie_figures is that the name are trimmed of whitespace
request_name = strtrim(request_name);

if isempty(fig_handle)
    % We have requested to create a new figure
    if request_current
        % Keep an already existing genie_figure with the requested name that
        % has 'current' status, if there is one.
        genie_figure_keep(request_name)
    end
    genie_figure_create_internal(fig_handle, request_name, request_current)
    
else
    % We have requested to update an existing genie_figure, or convert a non-
    % genie_figure to a genie_figure
    
    % We need to consider the possibility of a clash with other genie_figures
    % with the same name as that requested for the genie_figure we wish to
    % update or the non-genie_figure we wish to convert. If our genie_figure has
    % status 'current' then a name change alone will clash with an existing
    % genie_figure with that name and status 'current'; similarly if we convert
    % a non-genie_figure and the requested status is 'current'.
    % To avoid problems, 'keep' the existing genie_figure, or convert the non-
    % genie_figure into a genie_figure with 'keep' status. This is because we
    % can have as many genie_figures with 'keep' status of the same name as we.
    % like. Afterwards, we can then set our figure to the requested status
    % using the function genie_figure_keep or genie_figure_make_cur because they
    % look after the checking of the status of all genie_figures.
    
    % Update or convert the figure as described above
    [ok, ~, name] = is_genie_figure(fig_handle);
    if ok && ~strcmp(name, request_name)
        % The figure is already a genie_figure and we want to change the name.
        genie_figure_keep(fig_handle)   % does nothing if present status 'keep'
    end
    is_current = false;
    genie_figure_create_internal(fig_handle, request_name, is_current)
    
    % Now set to the requested status
    if request_current
        genie_figure_make_cur(fig_handle)
    else
        genie_figure_keep(fig_handle)
    end
end


%-------------------------------------------------------------------------------
function [ok, request_current] = is_argument_status (arg)
% Check if the argument is an unambiguous abbreviation of '-current' or '-keep'.
% Returns:
% - ok==false if no, & request_current ==[];
% - ok==true if yes, & request_current ==true if '-current' or false if '-keep'

ok = is_string(arg) && numel(arg)>=2 && ...
    (strncmpi(arg, '-current', numel(arg)) || strncmpi(arg, '-keep', numel(arg)));
% The argument is one of the two valid options for status
if ok
    request_current = (lower(arg(2:2))=='c');   % lower(arg) begins '-c' or '-k'
else
    request_current = [];
end
    

%-------------------------------------------------------------------------------
function genie_figure_create_internal (fig_handle, fig_name, request_current)
% Create a genie_figure with the requested name snd status
% This internal function does not check consistency of the creation of a
% 'current' status figure with any other genie_figures of the same name. That is
% assumed to have been dealt with in the calling function.


newfig = isempty(fig_handle);
fig_name = strtrim(fig_name);

% genie_figure tags for the 'current' and 'keep' status figures
tag_current = [fig_name,'$current$'];
tag_keep = [fig_name,'$keep$'];

% Values for figure and uimenu properties
if request_current
    tag = tag_current;
    enable_keep_menu = 'on';
    enable_current_menu = 'off';
else
    tag = tag_keep;
    enable_keep_menu = 'off';
    enable_current_menu = 'on';
end

% Create figure or reset properties on an existing figure
if newfig
    % New figure
    colordef white;
    fig_handle = figure;
    set(fig_handle, 'Name', fig_name, 'Tag', tag, 'PaperPositionMode', 'auto', ...
        'Color', 'white', 'toolbar', 'figure');
    
    % Set the size of the newly created figure to match the dimensions of the
    % most recently active genie_figure with the same name. Otherwise stay with
    % the default figure size that the figure was created with.
    fig_handle_keep = findobj('Type', 'figure', 'Tag', tag_keep);
    if ~isempty(fig_handle_keep)
        % Need to set the units of the new figure to those of the one whose size
        % we are going to copy before changing the size.
        set(fig_handle, 'Units', get(fig_handle_keep(1), 'Units'));
        set(fig_handle, 'Position', get(fig_handle_keep(1), 'Position'));
    end
    
else
    % Existing figure
    set(fig_handle, 'Name', fig_name, 'Tag', tag, 'PaperPositionMode', 'auto')
end

% Delete 'keep' and 'make current' menus, if present - a cleanup operation
delete(findobj(fig_handle, 'Type', 'uimenu', 'Tag', 'keep'));
delete(findobj(fig_handle, 'Type', 'uimenu', 'Tag', 'make_cur'));

% Create menu option to be able to keep figure
h = uimenu(fig_handle, 'Tag', 'keep', 'Label', 'Keep', ...
    'Enable', enable_keep_menu);
uimenu(h, 'Label', 'Keep figure', 'Callback', 'genie_figure_keep(gcf);');

% Create menu option to be able to make old plot cut figures current
h = uimenu(fig_handle, 'Tag', 'make_cur', 'Label', 'Make Current', ...
    'Enable', enable_current_menu);
uimenu(h, 'Label', 'Make Figure Current', 'Callback', 'genie_figure_make_cur(gcf);');
