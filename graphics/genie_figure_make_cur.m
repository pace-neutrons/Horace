function genie_figure_make_cur(fig)
% Make requested figure current for plotting
%
%   >> genie_figure_make_cur      % make the active figure current
%   >> genie_figure_make_cur(fig) % make the numbered or named figure current

% Based on routines taken from mslice

% *** Should make all the unique figures current - that is the multi-name equivalent of genie_figure_keep
% *** Currently objects if more than one figure

% Determine which figures to make current
if ~exist('fig','var')||(isempty(fig)),
    if isempty(findall(0,'Type','figure'))
        disp('No current figure exists - no figure to make current.')
        return
    else
        fig=gcf;
    end
else
    [fig,ok,mess]=genie_figure_handle(fig);
    if ~ok, error(mess), end
    if isempty(fig)
        disp('No figure with given name or figure number - no figure to make current.')
        return
    elseif numel(fig)>1
        error('More than one figure requested to be made current - not possible.')
    end
end

% Read figure tag, return if empty or if old figure tab could not be identified
tag=get(fig,'Tag');
tag=strtrim(tag);
if isempty(tag)
    disp('Figure has no current tag. Cannot determine which type of plot it contains. No action taken.');
    return;
end

if ~strncmp('$keep$',tag,6)
    disp('The figure tag is not the format $keep$<figure tag>. No action taken.');
    return;
end

% Extract original tag of figure
tag=tag(7:end);
if isempty(tag)
    disp('The original figure tag appears to be empty. No action taken.');
    return;
end

% Keep all other figures with the same original tag
h=findobj('Type','figure','Tag',tag);
for i=1:numel(h),
    genie_figure_keep(h(i));
end

% Put original tag and enable keep option on current figure
set(fig,'Tag',tag);
h=findobj(fig,'Type','uimenu','Tag','keep');
if ~isempty(h),
    set(h,'Enable','on'),
end

% Disable Make Current uimenu option for current figure
h=findobj(fig,'Type','uimenu','Tag','make_cur');
if ~isempty(h),
    set(h,'Enable','off'),
end
