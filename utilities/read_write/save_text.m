function save_text(w,file)
% Save cell array of strings to ascii file. Inverse of read_text.
%
%   >> save_text (w)        % prompts for file to write to
%   >> save_text (w, file)  % write to named file


% Check input data
% ----------------
[ok,wout]=str_make_cellstr(w);
if ~ok
    error('Check input is a string or a cell array of strings')
end

% Get file name - prompting if necessary
% --------------------------------------
if ~exist('file','var'), file='*.mat'; end
[file_full,ok,mess]=putfilecheck(file);
if ~ok, error(mess), end

% Write data to file
% ------------------
fid=fopen(file_full,'wt');
for j=1:numel(wout)
    fprintf(fid,'%s\n', wout{j});
end
fclose(fid);
