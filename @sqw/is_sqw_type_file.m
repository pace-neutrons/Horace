function [sqw_type, ndims, data_source, mess] = is_sqw_type_file(sqw, infile)
% Determine if file contains data of an sqw-type object or dnd-type sqw object
% 
%   >> [sqw_type, ndims, data_source, mess] = is_sqw_type_file(sqw, infile)
%
% Input:
% --------
%   sqw         Dummy sqw object used to enforce a call to this method
%   infile      File name, character array of file names, or cellstr of file names
%
% Output:
% --------
%   sqw_type    =true  if sqw-type contents; =false if dnd-type contents (array)
%   ndims       Number of dimensions (array if more than one file)
%   data_source Structure (or array of structures) with information about the data file
%       data_source.keyword     '$file_data'
%       data_source.file        Input file name
%       data_source.sqw_type    How to read data file: =true if sqw_type, =false if dnd_type
%       data_source.ndims       Dimensions of the sqw object
%   mess        Error message; blank if no errors, non-blank otherwise

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Check input file argument
if ischar(infile)
    infile=cellstr(infile);
elseif ~iscellstr(infile)
    sqw_type=[]; ndims=[]; data_source=[];
    mess='File name(s) must be character array or cell array of character strings';
    return
end

for i=1:numel(infile)
    if length(size(infile{i}))~=2 || size(infile{i},1)~=1
        sqw_type=[]; ndims=[]; data_source=[];
        mess='File name(s) must be non-empty character array or cell array of character strings';
        return
    elseif ~exist(infile{i},'file')
        sqw_type=[]; ndims=[]; data_source=[];
        mess=['File does not exist: ',infile{i}];
        return
    end
end
    
% Simply an interface to private function that we wish to keep hidden
sqw_type=true(size(infile));
ndims=zeros(size(infile));
for i=1:numel(infile)
    if get(hdf_config,'use_hdf')
        data_file=sqw_hdf(infile{i},'-no_new');
        sqw_type(i)=data_file.pixels_present;
        ndims(i)=numel(data_file.signal_dims);
        % closes the hdf 5 and its handles from memory rather then deleting the file
        data_file.delete();
    else
        [sqw_type_tmp, ndims_tmp, mess] = get_sqw_type_from_file (infile{i});   % must use temporary output arguments as may be unfilled if error
        if ~isempty(mess)
            sqw_type=[]; ndims=[]; data_source=[];
            return
        end
        sqw_type(i)=sqw_type_tmp;
        ndims(i)=ndims_tmp;
    end
    
    % Wrap file name in a structure with a key to identify the file as being the input sqw data
    if i==1
        data_source.keyword='$file_data';
        data_source.filename=infile{i};
        data_source.sqw_type=sqw_type(i);
        data_source.ndims=ndims(i);
        if numel(infile)>1
            data_source=repmat(data_source,size(infile));
        end
    else
        data_source(i).filename=infile{i};
        data_source(i).sqw_type=sqw_type(i);
        data_source(i).ndims=ndims(i);
    end
end
mess='';
