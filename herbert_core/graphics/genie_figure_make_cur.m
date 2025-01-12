function genie_figure_make_cur (fig)
% Make one genie_figure active for plotting for each of a selection of names
%
% Make the current figure the active genie_figure of its name (but only if it a
% genie_figure):
%   >> genie_figure_make_cur
%
% Make one genie_figure active for each of the name(s) of figures with selected
% figure name(s), number(s), or handle(s), if there is one available:
%   >> genie_figure_make_cur (fig)
%
% Make one of each genie_figure name active, if there is one available:
%   >> genie_figure_make_cur ('-all')
%
% Only operates on genie_figures, that is, those with the 'keep'/'make_cur' menu
% items.
% If more than one figure with the same name is provided, then the most
% recently active one is made current.
%
% Input:
% ------
%   fig         Figure name or cellstr of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
%               If fig is not given, or is [], the function uses the current
%              figure as input, if one exists.
%
%               Note: an empty character string or one containing just
%              whitespace is a valid name: the name is '' i.e. the empty string.
%
%               If fig is set to '-all', then the function makes one of each
%              genie_figure name have status 'current', so long as there is a
%              genie_figure available with that name.
%
% The genie_figure that is given 'current' status out of all those with the same
% figure name is chosen as follows:
%
% - fig is not given:
%     The current figure (as returned by gcf) becomes the current genie_figure,
%     if indeed the current figure is a genie_figure.
%
% - fig is name(s):
%     For each name, if there is a current genie_figure then no change;
%     if there is no current genie_figure with that name, the most recently
%     active figure with that name is chosen.
%
% - fig is figure number(s) or handle(s):
%     If only one number (or handle) is given for a particular figure name, then
%     that figure is chosen.
%     If more than one number (or handle) is given with the same figure name,
%     then the most recently active of those figures is chosen.


% Get figure handles
if ~exist('fig', 'var')
    fig_handle = get_figure_handle;     % current figure, if it exists
else
    fig_handle = get_figure_handle(fig);
end

% Determine which belong to genie_figures
[ok, current] = is_genie_figure(fig_handle);
if ~any(ok)
    disp(['No ''Keep''/''Make Current'' figure(s) with given name(s), ', ...
        'figure number(s) or figure handle(s)'])
    return
end

% Pick out the handles of genie_figures which have 'current' status
genie_fig_handle_curr = fig_handle(current);
genie_fig_handle_keep = fig_handle(ok & ~current);



% Make the most recent figure with a given name the current figure.
% Use the fact that the handle array is in order of activity

% Get handles to all (and only) genie_figures that have 'keep' status
fig_handle = fig_handle(ok & ~current);
if numel(fig_handle) > 1
    [fig_name, ind] = unique(get(fig_handle, 'Name'), 'first');
    fig_handle=fig_handle(ind);
end

for h=fig_handle'   % index of 'for' statement needs to be a row vector
    name=get(h,'Name');
    
    % Find the current figure with the given name, if there is one, and keep it
    hcur=findobj('Type','figure','Tag',[name,'$current$']);
    if ~isempty(hcur)
        genie_figure_keep(hcur)
    end
    
    % Set tag to indicate figure is current
    set(h, 'Tag', [name,'$current$']);
    
    % Enable 'Keep' uimenu option (should be present in a genie_figure, but
    % gracefully pass over any figures that have been mangled)
    hmenu = findobj(h, 'Type', 'uimenu', 'Tag', 'keep');
    if ~isempty(hmenu)
        set(hmenu, 'Enable', 'on'),
    end
    
    % Disable 'Make Current' uimenu option (should be present in a genie_figure,
    % but gracefully pass over any figures that have been mangled)
    hmenu = findobj(h, 'Type', 'uimenu', 'Tag', 'make_cur');
    if ~isempty(h)
        set(hmenu, 'Enable', 'off'),
    end
    
end
