function [filename, filepath] = put_mask_ascii (obj, file)
% Writes ASCII .msk file
%
%   >> [filename, filepath] = put_mask_ascii (data, file)
%
% See <a href="matlab:help('IX_mask/read_ascii');">IX_mask/read_ascii</a> for file format details and examples
%
% Input:
% ------
%   obj             Mask object
%   file            File name
%
% Output:
% -------
%   filename        Name of file excluding path
%   filepath        Path to file including terminating file separator


% Check file OK to write to
[file_tmp, ok, mess] = translate_write (strtrim(file));
if ~ok
    error ('HERBERT:IX_mask:io_error', ...
        ['Error resolving file name while attempting to write data to .msk file.\n', ...
        'File: %s\nMessage: %s'], strtrim(file), mess)
end

% Write ascii file
try
    str = iarray_to_str (obj.msk);
    fid = fopen (file_tmp, 'wt');
    for j=1:numel(str)
        fprintf (fid,'%s \n', str{j});
    end
    fclose(fid);
    
    [path, name, ext] = fileparts (file_tmp);
    filename = [name, ext];
    filepath = [path, filesep];

catch ME
    if exist('fid', 'var') && fid>0 && ~isempty(fopen(fid)) % close file, if open
        fclose(fid);
    end
    % Add cause to error message for user information
    mess = ['Error while attempting to write .msk file data to file:\n', file_tmp];
    causeException = MException('HERBERT:IX_mask:io_error', mess);
    ME = addCause(ME,causeException);
    rethrow(ME)
end
