function new_figure = genie_figure_create (fig_name)
% Find or, if necessary, create the current genie figure and make it the current figure
%
%   >> new_figure = genie_figure_create (fig_name)
%
% Input:
% ------
%   fig_name    Name of figure to be created  e.g. 'Genie 1D'
%
% Output:
% -------
%   new_figure  =true  : A new figure with the desired name was created.
%               =false : A figure with the desired name was already available
%                       for plotting (i.e. was not in the 'keep' state).
%                       This figure was made the current figure for plotting.


if isstring(fig_name)
    fig_name=strtrim(fig_name);
else
    error('Check input figure name is a character string')
end

name_curr=[fig_name,'$current$'];
name_keep=[fig_name,'$keep$'];

fig_handle=findobj('Tag',name_curr,'Type','figure');
if isempty(fig_handle)
    % No figure exists with tag matching a current instance of the requested figure name
    new_figure=true;
    colordef white;
    fig_handle=figure('Tag',name_curr,'PaperPositionMode','auto','Name',fig_name,'Color','white','toolbar','figure');
    
    % Find any kept figures and set current figure size to match the dimensions of the
    % figure with the most recently active figure with the same name. This
    % appears to be the handle with the smallest index (both pre-R2014b and
    % R2014b and later graphics)
    keep_fig_handle=findobj('Tag',name_keep,'Type','figure');
    if ~isempty(keep_fig_handle)
        set(fig_handle,'Position',get(keep_fig_handle(1),'Position'));
    end
    
    % Create menu option to be able to keep figure
    h=uimenu(fig_handle,'Label','Keep','Tag','keep','Enable','on');
    uimenu(h,'Label','Keep figure','Callback','genie_figure_keep(gcf);');
    
    % Create menu option to be able to make old plot cut figures current
    h=uimenu(fig_handle,'Label','Make Current','Tag','make_cur','Enable','off');
    uimenu(h,'Label','Make Figure Current','Callback','genie_figure_make_cur(gcf);');
    
else
    % Figure already exists as a current instance of the requested figure name.
    % By construction there can only be one such figure.
    new_figure = false;
    figure(fig_handle);    % make the figure the current figure
    
end
