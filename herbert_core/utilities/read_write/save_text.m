function [ok,err_message]=save_text(w,file)
% Save cell array of strings to ascii file. Inverse of read_text.
%
%   >> save_text (w)        % prompts for file to write to
%   >> save_text (w, file)  % write to named file

if nargout>0
    throw = false;
else
    throw = true;
end
err_message = '';
%
% Check input data
% ----------------
[ok,wout]=str_make_cellstr(w);
if ~ok
    err_message = 'Check input is a string or a cell array of strings';
    if throw
        error(err_message);
    else
        return;
    end
end

% Get file name - prompting if necessary
% --------------------------------------
if ~exist('file', 'var')
    file='*.mat';
    [file_full,ok,mess]=putfilecheck(file);
    if ~ok, error(mess), end
else
    file_full = file;
end

% Write data to file
% ------------------
fid=fopen(file_full,'wt');
clob = onCleanup(@()fclose(fid));
if fid<1
    err_message = sprintf('Can not open file %s for writing:',file_full);
    if throw
        error(err_message);
    else
        ok = false;
        return;
    end
end
for j=1:numel(wout)
    fprintf(fid,'%s\n', wout{j});
end
clear clob;
