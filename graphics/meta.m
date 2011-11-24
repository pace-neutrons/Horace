function meta(fig)
% Make a copy of the current figure to meta file. 
%
%   >> meta          % meta file from current figure
%   >> meta(fig)     % meta file from given figure
%
% On windows, this function puts the file in the clipboard so that it can be pasted
% directly into Word, Powerpoint etc.

% Determine which figure(s) to keep
if ~exist('fig','var')||(isempty(fig)),
    if isempty(findall(0,'Type','figure'))
        error('No current figure exists - cannot create meta file.')
    else
        fig=gcf;
    end
else
    [fig,ok,mess]=genie_figure_handle(fig);
    if ~ok, error(mess), end
    if isempty(fig)
        error('No figure with given name or figure number - cannot create meta file.')
    elseif numel(fig)>1
        error('Can only create meta file from a single figure')
    end
end

print('-dmeta','-noui',['-f',num2str(fig)]);
