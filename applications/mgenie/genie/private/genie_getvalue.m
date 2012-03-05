function w=genie_getvalue(nam)
% Get named variable from ISIS raw file.
%
%   >> w=genie_getvalue
%
% This should be the only gateway to retrieve data values

global mgenie_globalvars

genie_handle=mgenie_globalvars.opengenie_handle;
if ~isempty(genie_handle);  % opengenie is available
    if nargin==0        % inquire about source being used by genie
        command_line=strcat('w <~ cfn()');
        invoke(genie_handle,'AssignHandle',command_line,'');
        w = invoke(genie_handle, 'GetValue', 'w');
        invoke(genie_handle,'AssignHandle','free "w"','');   % clear w immediately to reduce memory costs

    elseif nargin==1    % get data from default source
        command_line=strcat('w <~ get("',nam,'")');          % w <~ get(...) avoids a double copy
        invoke(genie_handle,'AssignHandle',command_line,'');
        w = invoke(genie_handle, 'GetValue', 'w');           % works with character arrays too
        invoke(genie_handle,'AssignHandle','free "w"','');   % clear w immediately to reduce memory costs

    else
        error ('Wrong number of arguments')
    end
    
else
    error('Command cannot be executed because OpenGenie was not found')
end
