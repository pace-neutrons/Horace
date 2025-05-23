function genie_figure_make_cur (fig)
% Set genie_figure(s) active for plotting
%
% If the current figure is a genie_figure, make it the active genie_figure:
%   >> genie_figure_make_cur
%
% Make one genie_figure active for each of the name(s) of figures with selected
% figure name(s), number(s), or handle(s), if there is one available:
%   >> genie_figure_make_cur (fig)
%
% Make one of each genie_figure name active, if there is one available:
%   >> genie_figure_make_cur ('-all')
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
%     and none of them is already the current genie_figure, then the most
%     recently active of those figures is chosen.


% Get figure handles
if ~exist('fig', 'var')
    fig_handle = get_figure_handle;     % current figure, if it exists
else
    fig_handle = get_figure_handle(fig);% output could be an array of handles
end

% Determine which belong to genie_figures
ok = is_genie_figure(fig_handle);
if ~any(ok)
    return  % no genie_figures found, so nothing to do
end

% Pick out the handles of those figures that are genie_figures
% There is at least one if this point has been reached
fig_handle = fig_handle(ok);

% Get unique genie_figure names
if numel(fig_handle)>1
    fig_name = unique(get(fig_handle, 'Name'));     % output is cell array
else
    fig_name = {get(fig_handle, 'Name')};   % make output a cell array
end

% Loop over unique genie_figure names
for i = 1:numel(fig_name)
    % Figure handles for a particular genie_figure name, in order of decreasing
    % recent active status (that is, h(1) is the most recently active, h(2) is
    % the net most recently active etc.
    h = get_figure_handle(fig_name{i});
    
    % Pick out those figures with the genie_figure name that are in the input
    % argument, fig, in decreasing order of recent active status
    ok = ismember(h, fig_handle);
    h = h(ok);
    
    % If one of those figures has the genie_figure 'current' status, then no
    % need to do anything; if none of them have, set the most recently active
    % with the genie_figure 'current' status.
    hcur = findobj('Type', 'figure', 'Tag', [fig_name{i},'$current$']);
    if isempty(hcur) || ~any(h==hcur)
        % Keep the current figure, if there is one
        if ~isempty(hcur)
            genie_figure_keep(hcur)
        end
        
        % Set tag to indicate figure is current
        set(h(1), 'Tag', [fig_name{i},'$current$']);
        
        % Enable 'Keep' uimenu option (should be present in a genie_figure, but
        % gracefully pass over any figures that have been mangled)
        hmenu = findobj(h(1), 'Type', 'uimenu', 'Tag', 'keep');
        if ~isempty(hmenu)
            set(hmenu, 'Enable', 'on')
        end
        
        % Disable 'Make Current' uimenu option (should be present in a genie_figure,
        % but gracefully pass over any figures that have been mangled)
        hmenu = findobj(h(1), 'Type', 'uimenu', 'Tag', 'make_cur');
        if ~isempty(h(1))
            set(hmenu, 'Enable', 'off')
        end
    end
end
