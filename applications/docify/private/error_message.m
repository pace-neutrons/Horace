function msg=error_message(msgcell)
% Create a message from a cell array of strings with carriage retursn as required
% To use the output, use the general form of the error function:
%   >> error('dummy:dummy',msg)
%
% Replaces '\' with '\\' in each string - so no control characters are permitted.

if ~isempty(msgcell)
    if iscellstr(msgcell)
        msg=format_str(msgcell{1});
        for i=2:numel(msgcell)
            msg=[msg,'\n',format_str(msgcell{i})];
        end
    else
        msg=format_str(msgcell);
    end
else
    msg='';
end

%--------------------------------------------------------------------------
function msg_out=format_str(msg)
% Because the string has control characters, cannot just write strings as is

msg_out=regexprep(msg,'\','\\\');
msg_out=regexprep(msg_out,'%','%%');
