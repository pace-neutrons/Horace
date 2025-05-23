function varargout = genie_figure_set_target (varargin)
% Set the current figure and current axes according to the requested plot target
%
% >> genie_figure_set_target ()             % current figure
% >> genie_figure_set_target ([])           % current figure
% >> genie_figure_set_target (target)       % indicated target (name, figure
%                                           % number or handle, or axes handle
%
% >> genie_figure_set_target (..., '-existing') % only if it exists
%
% >> new_figure = genie_figure_set_target (...)
%
% Input:
% ------
%   target      Target for plotting:
%               figure name: - If there is one or more genie_figures with the
%                              name, set the one with 'current' status as the
%                              target, or, if they all have 'keep' status,
%                              create a new genie_figure with the name and with
%                              'current' status.
%                            - If there are no genie_figures with the name but
%                              there are one or more plot with that name that
%                              aren't genie_figures, use the most recently
%                              active one as the target for the plot.
%                            - If there are no figures with the name, create a
%                              genie_figure with the name, give it 'current'
%                              status, and make it the target for the plot.
%
%               figure number or handle:
%                            - If a figure with that number or handle already
%                              exists, use it as the target for the plot.
%                              [If doesn't exist, throws an error]
%
%               axes_handle: - Axes handle to be used as the target of the plot,
%                              if the axes exist.
%                              [If doesn't exist, throws an error]
%
%             missing or []: - If the current figure exists, set it as the
%                              target
%                            - Otherwise, create a nameless genie_figure
%
% Optional argument:
%   'existing'  If present, the requested target must already exist.
%               This is not relevant in the case of a figure or axes handle,
%               as they have to exist anyway to be a valid plot target.
%   
%
% Output:
% -------
%   new_figure  True if a new figure had to be created to be the target.
%               False if an existing figure is the target.
%
%               If the caller does not request an output argument, then none is
%               printed (equivalent to calling with a semi-colon at the end,
%               that is: >> genie_figure_set_target;)


% Get the requested target and determine if creation of a new figure is allowed
narg = nargin;
if narg>=1 && is_string(varargin{end}) && numel(varargin{end})>=2 &&...
        strncmpi(varargin{end},'-existing',numel(varargin{end}))
    newfig_permitted = false;
    narg = narg - 1;
else
    newfig_permitted = true;
end

if narg==0
    target = [];    % indicates current figure, if there is one
elseif narg==1
    target = varargin{1};
else
    error('HERBERT:graphics:invalid_argument', ...
        'Check the number of input arguments and/or validity of options ')
end

% Define function to more strictly check graphics object
isscalarGraphics = @(val,Type)(isscalar(val) && isgraphics(val,Type));

% Set the target for plotting
if isscalarGraphics(target, 'axes')
    % Valid axes handle (i.e. handle to axes that have not been deleted)
    axes(target)    % set the target as the current axes
    new_figure = false;
    
elseif isscalarGraphics(target, 'figure')
    % Valid figure handle (i.e. handle to a figure that has not been deleted)
    % This captures both a figure handle and a figure number
    figure(target)  % set target as the current figure
    new_figure = false;
    
elseif is_string(target)
    % Character string, so use as the name of a figure. The rules are:
    % - If there is one or more genie_figures, use the one with 'current' status
    %   as the target, or create a new genie_figure with 'current' status.
    % - If no genie_figure with the name, then use the most recently active non-
    %   genie_figure with the name.
    % - Otherwise, create a genie_figure and give it 'current' status.
    fig_name = strtrim(target);
    
    fig_handle = findobj('Type', 'figure', 'Name', fig_name);   % could be array
    [ok, is_current] = is_genie_figure (fig_handle);
    if isempty(fig_handle) || any(ok)
        % Either there is no figure with the target name, or there is at least
        % one which is also a genie_figure. 
        % - If there is no figure with the target name:
        %       - Create a new genie_figure with 'current' status and make it
        %         the plot target.
        % - In the second case, 
        %       - If they all have 'keep' status, create a new genie_figure, 
        %         give it 'current' status and make it the plot target
        %       - If there is a genie_figure with 'current' status, make it the
        %         plot target.
        fig_handle_current = fig_handle(is_current);
        if isempty(fig_handle) || isempty(fig_handle_current)
            if newfig_permitted
                genie_figure_create(fig_name);
                new_figure = true;
            else
                error('HERBERT:graphics:invalid_argument', ...
                    ['Forbidden from creating a new figure with the ', ...
                    'requested name by the presence of the option ''-existing'''])
            end
        else
            figure(fig_handle_current);
            new_figure = false;
        end
    else
        % A figure exists with the name and it is not a genie_figure.
        % Make the most recently active figure with that name the current one
        % for plotting.
        figure(fig_handle(1))   % most recently active figure has index 1.
        new_figure = false;
    end
    
elseif isnumeric(target) && isempty(target)
    % Set the target to the current figure, if it exists, or create a nameless
    % genie_figure if it doesn't (if permitted).
    fig = get(groot,'CurrentFigure');
    if ~isempty(fig)
        figure(fig)
        new_figure = false;
    else
        if newfig_permitted
            genie_figure_create('');
            new_figure = true;
        else
            error('HERBERT:graphics:invalid_argument', ...
                ['Forbidden from creating a new figure by the presence ', ...
                'of the option ''-existing'''])
        end
    end
    
else
    error('HERBERT:graphics:invalid_argument', ...
        ['A target for plotting must be one of the following:\n', ...
        '- A character string (the figure name)\n', ...
        '- The figure number or figure handle of an existing figure\n', ...
        '- The axes handle of an existing set of axes'])
end
    
% Output only if requested
if nargout>0
    varargout{1} = new_figure;
end
