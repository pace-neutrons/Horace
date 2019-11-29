function genie_figure_keep(fig)
% Keep figure(s) so next plot appears in a new window
%
%   >> genie_figure_keep          % keep the current figure
%   >> genie_figure_keep(fig)     % keep the numbered or named figures
%   >> genie_figure_keep('-all')  % keep all figures
%
% Input:
% ------
%   fig         Figure name or cellstr of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
% Only operates on figures created with the keep/make_cur menu items.


% Determine which figure(s) to keep
if ~exist('fig','var'), fig=[]; end
if ishandle(fig)
    fig_handle = fig;
else
    [fig_handle,ok,mess] = get_figure_handle (fig);
    if ~ok, error(mess), end
end
[ok,curr] = is_genie_figure (fig_handle);
if ~any(ok)
    disp('No keep/make_current figure(s) with given name(s), figure number(s) or figure handle(s)')
    return
end

% Keep all current plots
for h=fig_handle(curr)'     % needs to be row vector here
    name=get(h,'Name');
    
    % Set tag to indicate figure is kept
    set(h,'Tag',[name,'$keep$']);
    
    % Disable Keep uimenu option, if present
    hmenu=findobj(h,'Type','uimenu','Tag','keep');
    if ~isempty(hmenu)
        set(hmenu,'Enable','off'),
    end
    
    % Enable Make Current uimenu option, if present
    hmenu=findobj(h,'Type','uimenu','Tag','make_cur');
    if ~isempty(h)
        set(hmenu,'Enable','on'),
    end
    
end
