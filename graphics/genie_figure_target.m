function [fig_out,ok,mess]=genie_figure_target(fig,newplot,default_fig_name)
% Get name for new genie figure, or handle to existing figure for overplotting
%
%   >> [fig_name,ok,mess]=genie_figure_target(fig,newplot,default_fig_name)
%
% Input:
% ------
%   fig                 Figure name, number or handle for plotting
%   newplot             True if new plot figure to be created, false if use
%                      existing axes if target figure window exists
%   default_fig_name    Default name of target genie_figure if fig is empty
%
%
% Output:
% -------
%   fig_out             Figure name, if genie_figure is to be target
%                       Figure handle if to overplot on existing plot
%   ok                  True if all no error, false otherwise
%   mess                Empty string if OK==true; error message otherwise
%
%
% By default, a figure name is interpreted to refer to a genie figure: the
% action will be (later on) to find the current genie figure with the given
% name, creating a new figure window if necessary.
%
% The exception is if we want to overplot, and there is a non-genie window
% but no genie windows (active or kept) with the given name. It is assumed
% that it was explicitly requested to plot on that named figure, genie
% figure or not.
%
% We can also specify to overplot on a figure with a given handle or
% figure number.


% Interpret fig as a name if can; if no fig, set to default figure name
if isempty(fig) && ~is_string(fig)
    fig_name=default_fig_name;
    
elseif is_string(fig) || (iscellstr(fig) && isscalar(fig) && is_string(fig))
    if is_string(fig)
        fig_name=strtrim(fig);
    else
        fig_name=strtrim(fig{1});
    end
end

% Now determine action to be performed and return fig_out
if newplot
    if exist('fig_name','var')  % function was passed something we think is a name
        fig_out=fig_name;
        ok=true;
        mess='';
    else
        fig_out=[];
        ok=false;
        mess='Figure name must be a character string for a new plot';
    end
    
else
    if exist('fig_name','var')  % function was passed something we think is a name
        [fig_handle,ok,mess]=get_figure_handle (fig_name);
        if ok
            if isempty(fig_handle) || any(is_genie_figure(fig_handle))
                fig_out=fig_name;
            else
                h=findobj('Tag',fig_name,'Type','figure');
                if ~isempty(h)
                    fig_out=h(1);   % most recently active
                else
                    fig_out = [];
                end
            end
        else
            fig_out=[];
        end
    else
        [fig_handle,ok,mess]=get_figure_handle_single (fig);
        if ok
            fig_out=fig_handle;
        else
            fig_out=[];
        end
    end
end
