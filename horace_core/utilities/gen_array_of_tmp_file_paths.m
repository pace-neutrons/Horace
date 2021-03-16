function paths = gen_array_of_tmp_file_paths(nfiles, prefix, base_dir, ext)
% Generate a cell array of unique file paths within the given base directory
% The format of the file names follows:
%   <prefix>_<36_char_UUID>_<counter_with_padded_zeros>.<ext>
%
%  >> gen_array_of_tmp_file_paths(nfiles, prefix, base_dir)
%  >> gen_array_of_tmp_file_paths(nfiles, prefix, base_dir, ext)
%
% Input:
% ------
% nfiles    The number of file names to generate, must be a positive integer.
% prefix    The prefix for the file names, must be a char or a string.
% base_dir  The directory for the file paths.
% ext       The file extension for the file paths. Optional, default is tmp.
%           Note this should not include the `.` separating path and extension.
%
% Output:
% -------
% paths     An array of unique file paths. A cell array of char arrays.
%
validateattributes(nfiles, {'numeric'}, {'positive', 'integer'}, 1);
validateattributes(prefix, {'char', 'string'}, {'scalartext'}, 2);
validateattributes(base_dir, {'char', 'string'}, {'scalartext'}, 3);
if ~exist('ext', 'var')
    ext = 'tmp';
else
    validateattributes(ext, {'char', 'string'}, {'scalartext'}, 4);
end

uuid = char(java.util.UUID.randomUUID());
counter_padding = floor(log10(nfiles)) + 1;
format_str = sprintf('%s_%s_%%0%ii.%s', prefix, uuid, counter_padding, ext);
paths = cell(1, nfiles);
for i = 1:nfiles
    paths{i} = char(fullfile(base_dir, sprintf(format_str, i))) ;
end

end
