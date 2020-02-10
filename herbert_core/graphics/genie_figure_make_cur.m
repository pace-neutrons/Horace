function genie_figure_make_cur(fig)
% Make requested figure(s) current for plotting
%
%   >> genie_figure_make_cur        % make the current figure active for plotting
%   >> genie_figure_make_cur(fig)   % make the numbered or named figure(s) active
%   >> genie_figure_make_cur('-all')% make one of each figure name active
%
% Input:
% ------
%   fig         Figure name or cellstr of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
% Only operates on figures created with the keep/make_cur menu items.
% If more than one figure with the same name is provided, then the most
% recently active is made current.


% Determine which figure(s) to make current
if ~exist('fig','var'), fig=[]; end
if isa(fig,'handle')
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

% Make the most recent figure with a given name the current figure
% Use the fact that the handle array is in order of activity
fig_handle=fig_handle(~curr);
if numel(fig_handle)>1
    [fig_name,ind]=unique(get(fig_handle,'Name'),'first');
    fig_handle=fig_handle(ind);
end

for h=fig_handle'   % needs to be row vector here
    name=get(h,'Name');
    
    % Find the current figure with the given name, if there is one, and keep it
    hcur=findobj('Type','figure','Tag',[name,'$current$']);
    if ~isempty(hcur)
        genie_figure_keep(hcur)
    end
    
    % Set tag to indicate figure is current
    set(h,'Tag',[name,'$current$']);
    
    % Enable keep uimenu option, if present
    hmenu=findobj(h,'Type','uimenu','Tag','keep');
    if ~isempty(hmenu)
        set(hmenu,'Enable','on'),
    end
    
    % Disable Make Current uimenu option, if present
    hmenu=findobj(h,'Type','uimenu','Tag','make_cur');
    if ~isempty(h)
        set(hmenu,'Enable','off'),
    end
    
end
