function genie_figure_keep (fig)
% Keep genie_figures with selected name(s) so next plot(s) appear in new window(s)
%
% Keep all genie_figures with the name of the current figure (but only if it is
% a genie_figure):
%   >> genie_figure_keep
%
% Keep all genie_figures with the name(s) of figures with selected figure
% name(s), number(s), or handle(s):
%   >> genie_figure_keep (fig)
%
% Keep all genie_figures:
%   >> genie_figure_keep ('-all')
%
% This function only operates on genie_figures, that is, those with the
% 'keep'/'make_cur' menu items.
%
%
% Input:
% ------
%   fig         Figure name or cell array of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
%               If fig is not given, or is [], the function uses the current
%              figure as input, if one exists.
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name is '' i.e. the empty string.
%
%               If fig is set to '-all', then the function keeps all
%              genie_figures with 'current' status.


% Get figure handles
if ~exist('fig', 'var')
    fig_handle = get_figure_handle;     % current figure, if it exists
else
    fig_handle = get_figure_handle(fig);% output could be an array of handles
end

% Determine which belong to genie_figures
[ok, current] = is_genie_figure(fig_handle);
if ~any(ok)
    warning(['''keep'' ignored - no ''Keep''/''Make Current'' figure(s) ', ...
        'with given name(s), figure number(s) or figure handle(s)'])
    return
end

% Pick out the handles of genie_figures which have 'current' status
genie_fig_handle_curr = fig_handle(current);

% Keep all the genie_figures with 'current' status. By construction, there is at
% most one genie_figure for each genie_figure name, and all others with the same
% name must have 'keep' status.
for h = make_row(genie_fig_handle_curr)  % index of 'for' must be a row vector 
    name = get(h, 'Name');
    
    % Set the figure tag to indicate the figure has 'keep' status
    set(h, 'Tag', [name,'$keep$']);
    
    % Disable the 'Keep' uimenu option (should be present in a genie_figure, but
    % gracefully pass over any figures that have been mangled)
    hmenu = findobj(h, 'Type', 'uimenu', 'Tag', 'keep');
    if ~isempty(hmenu)
        set(hmenu, 'Enable', 'off'),
    end
    
    % Enable the 'Make Current' uimenu option (should be present in a
    % genie_figure, but gracefully pass over any figures that have been mangled)
    hmenu = findobj(h, 'Type', 'uimenu', 'Tag', 'make_cur');
    if ~isempty(h)
        set(hmenu,'Enable','on'),
    end
end
