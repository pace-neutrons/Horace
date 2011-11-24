function new_figure = genie_figure_create (fig_name)
% Create a figure frame with a given name and make the current graphics window
%
%   >> new_figure = genie_figure_create (fig_name)
%
%   fig_name    Name of figure to be created  e.g. 'Genie 1D'
%               Default is 'Herbert'
%
%   new_figure  =true  : a figure frame with the desired name was created
%               =false : a figure with the desired name was available for plotting
%                        (i.e. was not in the 'keep' state)

% Based on routines taken from mslice

if isempty(fig_name)
    fig_name = 'Herbert';           % default figure name
elseif ~(ischar(fig_name) && size(fig_name,1)==1)
    error('Check input figure name')
end

fig=findobj('Tag',fig_name,'Type','figure');
if isempty(fig)
    % No figure exists with tag matching the requested figure name
    new_figure=true;
    colordef white;
    fig=figure('Tag',fig_name,'PaperPositionMode','auto','Name',fig_name,'Color','white','toolbar','figure');
    % Find any kept figures and set current figure size to match the dimensions of the
    % most recent old figure of the same type
    keepfig=findobj('Tag',['$keep$',fig_name],'Type','figure');
    if ~isempty(keepfig),
        keepfig=sort(keepfig);
        set(fig,'Position',get(keepfig(end),'Position'));
    end
    % Create menu option to be able to keep figure
    h=uimenu(fig,'Label','Keep','Tag','keep','Enable','on');
    uimenu(h,'Label','Keep figure','Callback','genie_figure_keep(gcf);');
    % Create menu option to be able to make old plot cut figures current
    h=uimenu(fig,'Label','Make Current','Tag','make_cur','Enable','off');
    uimenu(h,'Label','Make Figure Current','Callback','genie_figure_make_cur(gcf);');
    
else
    % Figure already exists; by construction there can only be one
    new_figure = false;
    figure(fig);    % make the current figure
end
