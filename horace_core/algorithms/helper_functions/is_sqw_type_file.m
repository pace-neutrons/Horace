function [sqw_type, num_dims, nfiles, filenames, ld] = is_sqw_type_file(infile)
% Determine if file contains data of an sqw-type object or dnd-type sqw object
%
%   >> [sqw_type, num_dims, nfiles, filenames,ld] = is_sqw_type_file(w, infile)
%
% Input:
% --------
%   w           Dummy sqw object, whose sole purpose is to direct call to this function
%   infile      File name, character array of file names, or cellstr of file names
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents (array)
%   num_dims    Number of dimensions (array if more than one file)
%   nfiles      Number of contributing spe data sets (array if more than one file)
%   filenames   Cell array of file names (even if only one file, this is still a cell array)
%   ld          list of loaders to get file information and load the file
% Throws if some requested files are missing

% Original author: T.G.Perring
%


% Check input file argument
if istext(infile) && ndims(infile) == 2
    filenames = strtrim(cellstr(infile));
elseif iscellstr(infile)
    filenames = strtrim(infile);
else
    error('HORACE:algorithms:invalid_argument',...
          'File name(s) must be character array or cell array of character strings');
end

for i=1:numel(filenames)
    if ~isrow(filenames{i})
        error('HORACE:algorithms:invalid_argument',...
              'File name(s) must be non-empty character array or cell array of character strings');
    elseif ~is_file(filenames{i})
        error('HORACE:algorithms:invalid_argument',...
              'File: %s does not exist. ',filenames{i});
    end
end

% Simply an interface to private function that we wish to keep hidden
ld = sqw_formats_factory.instance().get_loader(filenames);
if ~iscell(ld)
    ld = {ld};
end

[sqw_type, num_dims, nfiles] = cellfun(@get_sqw_type_from_ld, ld);

end

function [sqw_type, num_dims, nfiles] = get_sqw_type_from_ld(ld)
% Get sqw_type and dimensionality of an sqw file on disk
%
%   >> [sqw_type, num_dims, nfiles] = get_sqw_type_from_loader (ld)
%
% Input:
% --------
%   ld   -- initialized loader
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents
%   num_dims       Number of dimensions
%   nfiles      Number of contributing spe data sets (=0 if not sqw-type)

% Original author: T.G.Perring
%

sqw_type = ld.sqw_type;
num_dims = ld.num_dim;
if sqw_type
    nfiles = ld.num_contrib_files;
else
    nfiles = 0;
end

end
