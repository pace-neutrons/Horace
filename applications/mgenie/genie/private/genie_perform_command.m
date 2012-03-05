function genie_perform_command (cmd)
% Perform an opengenie command
%
%   >> genie_perform_command (cmd)

global mgenie_globalvars

genie_handle=mgenie_globalvars.opengenie_handle;
if ~isempty(genie_handle);  % opengenie is available
    if nargin==1
        invoke(genie_handle,'AssignHandle',cmd,'')
    else
        error ('Wrong number of arguments')
    end
else
    error('Command cannot be executed because OpenGenie was not found')
end
