function msk = get_mask (filename)
% Read an ASCII .msk file
%
%   >> msk = get_mask (filename)
%
% Input:
% ------
%   filename        Name of mask file from which to read data
%
% Output:
% -------
%   msk             Numeric array
%
%
% Format of a mask file:
% ----------------------
% Lines of data with integer sequences separated by spaces or commas e.g.
%       11:34,55-70,80
% Blank lines and comment lines (lines beginning with ! or %) are skipped
% over. Comments can also be put at the end of lines


% Remove blanks from beginning and end of filename
[file_tmp, ok, mess] = translate_read (strtrim(filename));
if ~ok
    error ('IX_mask:get_mask:io_error', mess)
end

% Read file (use matlab, as files are generally small, so C++ code not
% really necessary)
str = strtrim (textcell(file_tmp));
nline = numel(str);
if nline==0
    error ('IX_mask:get_mask:io_error', 'Data file is empty')
end

% Process data from file
nmax = 1e8;   % in case there is some silly mistake in the syntax
[msk, le_nmax] = str_to_iarray (str, nmax);
if ~le_nmax
    error ('IX_mask:get_mask:io_error', ['More than ',num2str(nmax),...
        ' masked spectra encountered - possible a syntax error in the file'])
end
