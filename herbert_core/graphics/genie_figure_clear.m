function genie_figure_clear (varargin)
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
% Input:
% ------
%   fig_handle      Handle to a figure that currently exists
%
%   'reset'         If absent, then a clear is performed just as clf or
%                   clf(fig_handle), that is delete all children of the figure
%                   with visible handles (apart from the 'keep' and
%                   'make_current' menus)
%
%                   If present, then a full reset of the figure is performed, in
%                   which all children (visible handles or not) are deleted
%                   except the 'keep' and 'make_current' menu items, and the
%                   figure properties are set to the defaults except for the
%                   genie_figure specific default settings.


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
