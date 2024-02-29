function [filename, filepath] = put_map_ascii (obj, file)
% Writes ASCII .map file
%
%   >> [filename, filepath] = put_map_ascii (obj, file)
%
% See <a href="matlab:help('IX_map/read_ascii');">IX_map/read_ascii</a> for file format details and examples
%
% Input:
% ------
%   obj             Map object
%   file            File name
%
% Output:
% -------
%   filename        Name of file excluding path
%   filepath        Path to file including terminating file separator


% Check file OK to write to
[file_tmp, ok, mess] = translate_write (strtrim(file));
if ~ok
    error('HERBERT:IX_map:io_error', ...
        ['Error resolving file name while attempting to write data to .map file.\n', ...
        'File: %s\nMessage: %s'], strtrim(file), mess)
end

% Write ascii file
try
    nwkno = obj.nwkno;
    ns = obj.ns;
    s = obj.s;
    wkno = obj.wkno;
    
    ns_end = cumsum(obj.ns);
    ns_beg = ns_end - obj.ns + 1;
    fid = fopen(file_tmp,'wt');
    fprintf(fid, '%d \n', nwkno);
    for i=1:nwkno
        fprintf(fid, '%d ! Workspace number\n', wkno(i));
        fprintf(fid, '%d ! Number of spectra\n', ns(i));
        str = iarray_to_str(s(ns_beg(i):ns_end(i)));    % str == '' if no spectra
        for j=1:numel(str)  % nothing written if number of spectra is zero
            fprintf(fid, '%s \n', str{j});
        end
    end
    fclose(fid);
    
    [path, name, ext] = fileparts(file_tmp);
    filename = [name, ext];
    filepath = [path, filesep];
    
catch ME
    if exist('fid', 'var') && fid>0 && ~isempty(fopen(fid)) % close file, if open
        fclose(fid);
    end
    % Add cause to error message for user information
    mess = ['Error while attempting to write .map file data to file:\n', file_tmp];
    causeException = MException('HERBERT:IX_map:io_error', mess);
    ME = addCause(ME,causeException);
    rethrow(ME)
end
