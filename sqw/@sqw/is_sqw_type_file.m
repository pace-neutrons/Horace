function [sqw_type, ndims, nfiles, filename, mess,ld] = is_sqw_type_file(w,infile)
% Determine if file contains data of an sqw-type object or dnd-type sqw object
% 
%   >> [sqw_type, ndims, nfiles, filename, mess] = is_sqw_type_file(w, infile)
%
% Input:
% --------
%   w           Dummy sqw object, whose sole purpose is to direct call to this function
%   infile      File name, character array of file names, or cellstr of file names
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents (array)
%   ndims       Number of dimensions (array if more than one file)
%   nfiles      Number of contributing spe data sets (array if more than one file)
%   filename    Cell array of file names (even if only one file, this is still a cell array)
%   mess        Error message; blank if no errors, non-blank otherwise
%   ld          if mess is empty, list of loaders to get file information
%               and load the file

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Default return values if there is an error
sqw_type=[]; ndims=[]; nfiles=[];

% Check input file argument
if ischar(infile) && numel(size(infile))==2
    filename=strtrim(cellstr(infile));
elseif iscellstr(infile)
    filename=strtrim(infile);
else
    filename={};
    mess='File name(s) must be character array or cell array of character strings';
    return
end

for i=1:numel(filename)
    if length(size(filename{i}))~=2 || size(filename{i},1)~=1
        mess='File name(s) must be non-empty character array or cell array of character strings';
        return
    elseif ~exist(filename{i},'file')
        mess=['File does not exist: ',filename{i}];
        return
    end
end
    
% Simply an interface to private function that we wish to keep hidden
sqw_type=true(size(filename));
ndims=zeros(size(filename));
nfiles=zeros(size(filename));
try
    ld = sqw_formats_factory.instance().get_loader(filename);
    if ~iscell(ld)
        ld = {ld};
    end
catch ME
    mess = ME.msgtext;
    return;
end
for i=1:numel(filename)
    [sqw_type_tmp, ndims_tmp, nfiles_tmp] = get_sqw_type_from_ld(ld{i});   % must use temporary output arguments as may be unfilled if error
    sqw_type(i)=sqw_type_tmp;
    ndims(i)=ndims_tmp;
    nfiles(i)=nfiles_tmp;
end
mess='';

function [sqw_type, ndims, nfiles] = get_sqw_type_from_ld(ld)
% Get sqw_type and dimensionality of an sqw file on disk
%
%   >> [sqw_type, ndims, nfiles] = get_sqw_type_from_loader (ld)
%
% Input:
% --------
%   ld   -- initalized loader
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents
%   ndims       Number of dimensions
%   nfiles      Number of contributing spe data sets (=0 if not sqw-type)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


sqw_type = ld.sqw_type;
ndims = ld.num_dim;
if sqw_type
    nfiles = ld.num_contrib_files;
else
    nfiles = 0;
end


