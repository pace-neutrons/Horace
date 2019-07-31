function [ok,mess]=rename_file(source,destination)
% Rename a file. Attempts to use system commands to speed things up if can.
%
%   >> [ok,mess]=rename_file(source,destination)
%
% Input:
% ------
%   source          Source file name (charactger string)
%   destination     Destination file name (character string)
%
% Output:
% -------
%   ok              Status flag: true if all ok, false otherwise
%   mess            Error message if not OK; ='' otherwise
%
% If a error was encountered but there are no return arguments, then
% the error message is written to the command window.
%
% The reason this function exists is because the Matlab movefile is truly
% crap (at least on Windows): it makes a copy, then deletes the source.


% Check existence of files - side effect is to check that arguments are OK
try
    if exist(source,'file'), s_ex=true; else s_ex=false; end
    if exist(destination,'file'), d_ex=true; else d_ex=false; end
catch
    ok=false; mess='Check input arguments are characters strings';
    if nargout==0, error(mess), else return, end
end

if s_ex
    [spath,sname,sext]=fileparts(source); if isempty(spath), spath=pwd; end
else
    ok=false; mess='Source file does not exist';
    if nargout==0, error(mess), else return, end
end
[dpath,dname,dext]=fileparts(destination); if isempty(dpath), dpath=pwd; end
% Do nothing if destination is the same as the source
if ispc
    if strcmpi(fullfile(spath,[sname,sext]),fullfile(dpath,[dname,dext]))
        if nargout>0, ok=true; mess=''; else clear('ok','mess'), end, return
    end
elseif strcmpi(fullfile(spath,[sname,sext]),fullfile(dpath,[dname,dext]))
    if nargout>0, ok=true; mess=''; else clear('ok','mess'), end, return
end


% Rename file
try
    if ispc
        if strcmpi(spath,dpath)
            if d_ex, delete(destination), end   % DOS rename does not work if the destination exists
            [status,message]=dos(['rename ',source,' ',dname,dext]);
            if status==0    % status=0 is success it appears
                if nargout>0, ok=true; mess=''; else clear('ok','mess'), end, return
            end
        end
        % Attempt to use movefile if systsem rename fails - maybe Matlab has tied up the file, for example.
        [ok,mess]=movefile(source,destination);
    else
        [ok,mess]=movefile(source,destination);
    end
catch
    ok=false;
    mess='Unknown error attempting to rename file. Check input arguments';
end

% Package output
if ok
    if nargout>0, mess=''; else clear('ok','mess'), end
elseif ~ok && nargout==0
    error(mess)
end
