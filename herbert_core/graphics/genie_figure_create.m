function new_figure = genie_figure_create (fig_name)
% Find or create a genie_figure with the given name with status 'current'
% Set the figure as the current figure for Matlab graphics output.
%
%   >> new_figure = genie_figure_create (fig_name)
%
% For details about genie_figures, see notes below.
%
% Input:
% ------
%   fig_name    Name of genie_figure to be found or created  e.g. 'Genie 1D'
%               with genie_figure status 'current' This makes it the
%               genie_figure with that name that is the current figure for
%               Matlab graphics output.
%
% Output:
% -------
%   new_figure  =false : A figure with name fig_name was already available
%                       for plotting (i.e. had 'current' state). No
%                       new figure was created.
%               =true  : All figures named fig_name had 'keep' status, or no
%                       figures called fig_name existed. A new figure with
%                       name fig_name was created.
%
%
% Notes about genie_figures
% -------------------------
% A 'genie_figure' is one which has the 'Keep' and 'Make Current' functionality.
% They are used by Horace, Herbert and the Matlab mslice applications to make
% the management of collections of related figures convenient. For example,
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
%
%
% See also:
% genie_figure_


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
% presence of the uimenus alone is not sufficient as the visulaisation
% application mslice also has those uimenus.


% Check input is a single name (note: empty string is a valid genie_figure name)
if is_string(fig_name)
    fig_name = strtrim(fig_name);
else
    error('HERBERT:graphics:invalid_argument', ...
        'Check input figure name is a character string')
end

% 
tag_current = [fig_name,'$current$'];
tag_keep = [fig_name,'$keep$'];

fig_handle=findobj('Type', 'figure', 'Tag', tag_current);
if isempty(fig_handle)
    % No genie_figure with the requested name tag has 'current' status
    % Create a new genie_figure, with 'current' status
    new_figure = true;
    colordef white;
    fig_handle = figure('Name', fig_name, 'Tag', tag_current, ...
        'PaperPositionMode', 'auto', 'Color', 'white', 'toolbar', 'figure');
    
    % Set the size of the newly created figure to match the dimensions of the
    % most recently active genie_figure with the same name. Otherwise use the
    % default figure size.
    fig_handle_keep = findobj('Type', 'figure', 'Tag', tag_keep);
    if ~isempty(fig_handle_keep)
        set(fig_handle, 'Position', get(fig_handle_keep(1), 'Position'));
    end
    
    % Create menu option to be able to keep figure
    h = uimenu(fig_handle, 'Tag', 'keep', 'Label', 'Keep', 'Enable', 'on');
    uimenu(h, 'Label', 'Keep figure', 'Callback', 'genie_figure_keep(gcf);');
    
    % Create menu option to be able to make old plot cut figures current
    h = uimenu(fig_handle, 'Tag', 'make_cur', 'Label', 'Make Current', ...
        'Enable', 'off');
    uimenu(h, 'Label', 'Make Figure Current', 'Callback', ...
        'genie_figure_make_cur(gcf);');
    
else
    % A genie_figure with the requested name already exists with 'current' status
    % By the construction above there can only be one such figure.
    new_figure = false;
    figure(fig_handle);     % make the figure the current Matlab figure
    
end
