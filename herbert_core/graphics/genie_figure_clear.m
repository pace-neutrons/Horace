function varargout = genie_figure_clear (varargin)
% Clear a genie_figure except for the 'keep' and 'make_current' menus
%
%   >> genie_figure_clear               % clear current figure
%   >> genie_figure_clear ('reset')     % reset current figure
% 
%   >> genie_figure_clear (fig_handle)              % clear the specified figure
%   >> genie_figure_clear (fig_handle, 'reset')     % reset the specified figure
%
% Equivalent to Matlab function clf except that the defining qualities of a
% genie_figure are retained, namely the 'keep' and 'make_current' functionality.
% 
% With all the above:
%   >> fig_handle = genie_figure_clear (...)       % Return the figure handle
%
%
% Input:
% ------
%   fig_handle  Figure handle or figure number.
%               If the figure is not a genie_figure, then performs exactly the
%               same action as the matlab intrinsic function clf.
%
% Optional argument:
%   'reset'     If absent: clear figure just as clf or clf(fig_handle)
%               Deletes all children of the figure with visible handles.
%               (This is apart from the genie_figure 'keep' and 'make_current'
%               menus.)
%
%               If present: equivalent to clf('reset') or clf(fig_handle, 'reset')
%               A full reset of the figure is performed, in which all children
%               whether otr not they have visible handles are deleted, and the
%               figure properties are set to the defaults.
%               (This is apart from the 'keep' and 'make_current' menu items and
%               genie_figure specific default settings.)


% Determine if a clear or reset is to be performed
narg = numel(varargin);
if narg>0 && is_string(varargin{end}) && ~isempty(varargin{end}) &&...
        strncmpi(varargin{end}, 'reset', numel(varargin{end}))
    reset = true;
    narg = narg - 1;
else
    reset = false;
end

% Determine if figure handle provided
if narg==0
    fig_handle = gcf; % current figure - will be created if no figures exist
elseif narg==1
    fig_handle = varargin{1};
    if ~(isscalar(fig_handle) && isgraphics(fig_handle, 'figure'))
        error('HERBERT:graphics:invalid_argument', ...
            'Check input is a handle to an existing figure')
    end
else
    error('HERBERT:graphics:invalid_argument', ...
        'Unrecognised option - check the number and/or type of input arguments')
end

% Clear the figure
[is_genie, is_current, name] = is_genie_figure(fig_handle);

% Perform the Matlab standard clear
% If the figure is not a genie_figure, we want this standard behaviour anyway.
if reset
    clf(fig_handle, 'reset')
else
    clf(fig_handle)
end

% Now recover the genie_figure properties, if the figure was a genie_figure
if is_genie
    if is_current
        genie_figure_create (fig_handle, name, '-current')
    else
        genie_figure_create (fig_handle, name, '-keep')
    end
end

% Output only if requested
if nargout>0
    varargout{1} = fig_handle;
end
