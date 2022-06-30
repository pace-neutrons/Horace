function [fig_handle,ok,mess,valid] = get_figure_handle (fig)
% Return handle(s) of figure(s)
%
%   >> [fig_handle,ok,mess,valid] = get_figure_handle
%   >> [fig_handle,ok,mess,valid] = get_figure_handle (fig)
%   >> [fig_handle,ok,mess,valid] = get_figure_handle ('-all')
%
% Input:
% ------
%   fig         Figure name or cellstr of figure names
%          *OR* Figure number or array of figure numbers
%          *OR* Figure handle or array of figure handles
%
%               An empty character string or one containing just whitespace
%              is a valid name: the name will be '' i.e. the empty string.
%
%               If fig is not given, or an empty argument apart from a
%              character string, returns figure handle for the current
%              figure, if one exists.
%
%               If fig is '-all', then gets handles of all figures
%
% Output:
% -------
%   fig_handle  Column vector of handles of any figures with names that
%              match one of the input names. Figure names that do not exist
%              are simply ignored.
%               The same is true of figure numbers that do not exist or
%              figure handles that do not exist.
%   ok          True if no errors, false otherwise. OK can be true even if
%              there are no figure handles, so check the size of fig_handle
%              on return.
%   mess        Empty string if OK, error message if not OK
%   valid       Logical array (same size as fig) of which elements of fig
%              corresponded to valid figure(s) (Note that a name could
%              be the same for several figures).
%               If fig is empty or not an input argument then valid is 0x0
%              array


% Initialise output
ok=true;
mess='';

% Find figure handles
if nargin==0 || (isempty(fig) && ~is_string(fig))
    % Catch case of no input
    if isempty(findobj(0,'Type','figure'))
        fig_handle=empty_default_graphics_object();
    else
        fig_handle=gcf;
    end
    valid=true(0);
    
else
    % Consider case of input figure(s)
    if isnumeric(fig)   % could be array of figure handles (R2014a and earlier), or figure numbers
        if verLessThan('matlab','8.4')
            valid=ishandle(fig);
            fig_handle=fig(valid(:));
        else
            all_fig=findobj(0,'Type','figure');
            fig_num=get_figure_number(all_fig);
            [valid,loc]=ismember(fig,fig_num);
            fig_handle=all_fig(loc(valid(:)));
        end
        
    elseif ischar(fig) || iscellstr(fig)
        [ok,fig]=str_make_cellstr(fig);
        if ok
            fig=strtrim(fig);   % str_make_cellstr only trims trailing whitespace
            if numel(fig)==1 && strcmpi(fig{1},'-all')
                fig_handle=findobj(0,'Type','figure');
                valid=true(0);
            else
                fig_handle=[];
                valid=false(size(fig));
                for i=1:numel(fig)
                    tmp=findobj('name',fig{i},'type','figure');
                    if ~isempty(tmp)
                        valid(i)=true;
                        fig_handle=[fig_handle;tmp];
                    end
                end
                if isempty(fig_handle)
                    fig_handle=empty_default_graphics_object(); % consistency
                end
            end
        else
            [fig_handle,ok,mess,valid]=error_return('Check validity of figure name(s)',size(fig));
        end
        
    elseif isa(fig,'matlab.ui.Figure')
        % Handle(s) to graphics window(s) - will give false for versions earlier than 2014b
        valid=isvalid(fig);     % figures might have been deleted, but handles still exist
        fig_handle=fig(valid(:));
        
    else
        [fig_handle,ok,mess,valid]=error_return('Check validity of figure name(s)',size(fig));
    end
    
end

%--------------------------------------------------------------------------------------------------
function [fig_handle,ok,mess,valid]=error_return(mess,sz)
% Standard return arguments
fig_handle=empty_default_graphics_object();
ok=false;
valid=false(sz);
