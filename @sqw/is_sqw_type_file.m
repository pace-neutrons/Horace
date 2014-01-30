function [sqw_type, ndims, filename, mess] = is_sqw_type_file(w,infile)
% Determine if file contains data of an sqw-type object or dnd-type sqw object
% 
%   >> [sqw_type, ndims, data_source, mess] = is_sqw_type_file(sqw, infile)
%
% Input:
% --------
%   w           Dummy sqw object, whose sole purpose is to get to this function
%   infile      File name, character array of file names, or cellstr of file names
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents (array)
%   ndims       Number of dimensions (array if more than one file)
%   filename    Cell array of file names (even if only one file, this is still a cell array)
%   mess        Error message; blank if no errors, non-blank otherwise

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Default return values if there is an error
sqw_type=[]; ndims=[]; 

% Check input file argument
if ischar(infile) && numel(size(infile))==2
    filename=strtrim(cellstr(infile));
elseif iscellstr(infile)
    filename=strtrim(infile);
else
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
for i=1:numel(filename)
    [mess, sqw_type_tmp, ndims_tmp] = get_sqw_type_from_file (filename{i});   % must use temporary output arguments as may be unfilled if error
    if ~isempty(mess)
        sqw_type=[]; ndims=[];  % need to reset in case earlier succesful calls to get_sqw_type_from_file
        return
    end
    sqw_type(i)=sqw_type_tmp;
    ndims(i)=ndims_tmp;
end
mess='';
