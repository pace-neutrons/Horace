function genie_figure_keep(fig)
% Keep figure(s) so next plot appears in a new window
%
%   >> genie_figure_keep          % keep the active figure
%   >> genie_figure_keep(fig)     % keep numbered or named figures

% Based on routines taken from mslice

% Determine which figure(s) to keep
if ~exist('fig','var')||(isempty(fig)),
    if isempty(findall(0,'Type','figure'))
        disp('No current figure exists - no figures to keep.')
        return
    else
        fig=gcf;
    end
else
    [fig,ok,mess]=genie_figure_handle(fig);
    if ~ok, error(mess), end
    if isempty(fig)
        disp('No figure(s) with given name(s) or figure number(s) - no figures to keep.')
        return
    end
end

for i=1:numel(fig)
    % Read figure tag, skip if empty or if figure already kept
    tag=get(fig(i),'Tag');
    tag=strtrim(tag);
    if isempty(tag),
        disp('Figure has no current tag. No action taken.');
        continue;
    end
    if strncmp('$keep$',tag,6)
        continue;   % just ignore if already kept
    end
    
    % Keep figure, remember old tag and disable keep uimenu option, if present
    set(fig(i),'Tag',['$keep$' tag]);
    h=findobj(fig(i),'Type','uimenu','Tag','keep');
    if ~isempty(h),
        set(h,'Enable','off'),
    end
    
    % Enable Make Current uimenu option, if present
    h=findobj(fig,'Type','uimenu','Tag','make_cur');
    if ~isempty(h),
        set(h,'Enable','on'),
    end
    
end
