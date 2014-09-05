function [sqw_type, ndims, nfiles, filename, mess] = is_sqw_type_file(w,infile)
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
    
% Get information from files
sqw_type=true(size(filename));
ndims=zeros(size(filename));
nfiles=zeros(size(filename));
for i=1:numel(filename)
    [S,ok,mess] = get_sqw (filename{i},'-info');
    if ~isempty(mess)
        sqw_type=[]; ndims=[];  nfiles=[];  % need to reset in case earlier succesful calls to get_sqw
        return
    end
    info=S.info;
    sqw_type(i)=info.sqw_type;
    ndims(i)=info.ndims;
    nfiles(i)=info.nfiles;
end
mess='';
