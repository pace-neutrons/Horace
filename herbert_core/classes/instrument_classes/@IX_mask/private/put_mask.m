function [filename, filepath] = put_mask (msk, file)
% Writes ASCII .msk file
%   >> [filename, filepath] = put_mask (data, file)
%
% Input:
% ------
%   data            Mask object
%   file            File name
%
% Output:
% -------
%   filename        Name of file excluding path
%   filepath        Path to file including terminating file separator


% Check file OK to write to
[file_tmp, ok, mess] = translate_write (strtrim(file));
if ok
    [path, name, ext] = fileparts (file_tmp);
    filename = [name,ext];
    filepath = [path,filesep];
else
    error ('IX_mask:put_mask:io_error', mess)
end

% Write ascii file
try
    str = iarray_to_str (msk);
    fid = fopen (file_tmp,'wt');
    for j=1:numel(str)
        fprintf (fid,'%s \n', str{j});
    end
    fclose(fid);
    
catch ME
    if exist('fid', 'var') && fid>0 && ~isempty(fopen(fid)) % close file, if open
        fclose(fid);
    end
    rethrow (ME)
end
