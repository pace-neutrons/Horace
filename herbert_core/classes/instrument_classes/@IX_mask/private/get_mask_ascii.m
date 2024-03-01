function obj = get_mask_ascii (filename)
% Read an ASCII .msk file
%
%   >> obj = get_mask_ascii (filename)
%
% Input:
% ------
%   filename        Name of mask file from which to read data
%
% Output:
% -------
%   obj             IX_mask object
%
%
% Format of an ascii mask file:
% -----------------------------
% The file consists of lists of indices in various forms, for
% example '7 12:15, 5:-2:1' will specify [7,12,13,14,15,5,3,1])
%
% Blank lines and comment lines (lines beginning with ! or %) are ignored.
% Comments can also be put at the end of lines following ! or %.
% As an example of the full contents of a valid .msk file:
%
%           ! A little mask
%           60:-1:50,2-5,30-40
%           19-23
%
%           ! Another comment
%           38-42
%           10,11,12        ! in-line comment
%
%           % Matlab style comment
%           12, 32, 56-62   % another in-line comment


% Read lines from file
% --------------------
% Remove blanks from beginning and end of filename
[filename_full, ok, mess] = translate_read (strtrim(filename));
if ~ok
    error ('HERBERT:IX_mask:invalid_file_format', ...
        'Error resolving file name: %s.\nMessage: %s', strtrim(filename), mess)
end

% Read file (use matlab, as files are generally small, so C++ code not really necessary)
str = strtrim (textcell(filename_full));
nline = numel(str);
if nline==0
    obj = IX_mask();    % file is empty; return empty mask
    return
end

% Process data from file
% ----------------------
nmax = 1e8;   % some huge limit in case there is some silly mistake in the syntax
[msk, le_nmax] = str_to_iarray (str, nmax);
if ~le_nmax
    error ('HERBERT:IX_mask:io_error', ...
        ['More than %d masked indices encountered - possibly a syntax error ',...
        'in the file\nFile: %s\nLine: %s'], nmax, filename_full, str{iline})
end

obj = IX_mask(msk);
