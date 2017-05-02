function error_message(mess,opt)
% Throw an error message from a character string or cell array of strings
%
%   >> error_message(mess)
%   >> error_message (mess, '-squeeze')     % Squeeze out empty lines
%
% If the message is empty, then an error is still thrown.
%
% Note: No control characters are permitted as part of the message string(s)
% because to work with the Matlab error handler the function replaces '\' with
% '\\' in each string - and an accumlating set of other common replacements.


% Get option
if nargin==2
    if is_string(opt) && strncmpi(opt,'-squeeze',numel(opt))
        squeeze=true;
    else
        error('Unrecognised optional argument')
    end
else
    squeeze=false;
end

% Recast message and throw
if iscellstr(mess) && all(cellfun(@(x)(size(x,1)==1||isempty(x)),mess(:)))
    if ~isempty(mess)
        mess=deblank(mess(:));
        if squeeze
            ok=~cellfun(@isempty,mess);
            mess=mess(ok);
        end
        msg=format_str(mess{1});
        for i=2:numel(mess)
            msg=[msg,'\n',format_str(mess{i})];
        end
    else
        msg='';
    end
elseif is_string(mess)
    msg=deblank(mess);
else
    error('Input must be character string or cell array of strings')
end

ME=MException('error_message:throw',msg);
ME.throwAsCaller

%--------------------------------------------------------------------------
function msg_out=format_str(msg)
% Because the string has control characters, cannot just write strings as is

msg_out=regexprep(msg,'\','\\\');
msg_out=regexprep(msg_out,'%','%%');
