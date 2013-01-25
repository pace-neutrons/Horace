function [data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = parse_data_source (varargin)
% Resolve input arguments to sqw methods where a file may be the source of data.
%
%   >> [data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = ...
%                               parse_data_source (sqw_object, varargin)
%
%   >> [data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = ...
%                               parse_data_source (dummy_sqw_object, filename, varargin)
%
%   >> [data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = ...
%                               parse_data_source (dummy_sqw_object, data_source_struct, varargin)
%
% NOTE: File names must not begin with a dash, '-'. Strings beginning with a dash are
%       reserved for character keyword options.
%
% Input:
% ------
%   sqw_object          sqw object or array of sqw objects
% *OR*
%   dummy_sqw_object    Dummy sqw object (e.g. from call to sqw constructor with no input arguments)
%   filename            File name, or cell array of file names, containing Horace data
% *OR*
%   dummy_sqw_object    Dummy sqw object (e.g. from call to sqw constructor with no input arguments)
%   data_source_in      Data source structure or array of data source structures for data file(s)
%                      from an earlier call to this function. Data source structure has fields:
%                                 data_source_struct.keyword     '$file_data'
%                                 data_source_struct.file        Input file name
%                                 data_source_struct.sqw_type    How to read data file:
%                                                                  =true if read as sqw_type
%                                                                  =false if read dnd_type
%                                 data_source_struct.ndims       Dimensions of the sqw object
%                               Note that data_source.sqw_type is not necessarily the same as the
%                               type of data in the file e.g. if the file contains sqw_type data,
%                               we may still set the flag so that it is read as dnd-type data.
%
%  [All other input arguments are passed through in output argument args (see below)]
%
% Output:
% -------
%   data_source         *EITHER*
%                           Input sqw object oarray of objects, if this is the data source
%                       *OR*   
%                           Data source structure (or array of data source structures)
%                           for the file name(s) provided, or simply input data source structure
%                           if this was given.
%
%   args                Input argument list stripped of sqw_object or dummy_sqw_object, data_source_in
%   source_is_file      false: if sqw object input; true: file name(s) or data source structure [scalar]
%   sqw_type            Array of logical true or false according to each data object being sqw type or not
%   ndims               Array of the dimensions of the sqw objects
%   source_arg_is_filename Scalar logical:
%                           true:  data_source_in is a file name or cell array of file names
%                           false: Otherwise, that is:
%                               - data_source_in is a data source structure (see input arguments for details)
%                               - there is no data_source_in because the sqw object was the data source.
%                       Can use this argument in conjuction with the value of source_is_file to determine
%                       which if the three scenarios of data applies: sqw object, filename(s), data_source structure
%   mess                Error message: empty if no problems

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Parse input arguments
% ---------------------
if nargin>=2 && ~isempty(varargin{2}) && ((ischar(varargin{2})&&(varargin{2}(1:1)~='-'))||iscellstr(varargin{2}))
    % If the second argument is a non-empty character array or cellstr, then use this as the file name of the data source
    % [frequently we use empty character string '' to indicate a placeholder missing argument e.g. in sqw/cut
    try
        [sqw_type, ndims, data_source, mess] = is_sqw_type_file(sqw, varargin{2});
    catch
        mess = 'Unable to read sqw file(s) - check file(s) exist and are Horace data file(s) (sqw or dnd type binary file)';
    end
    if isempty(mess)
        if nargin>=3, args=varargin(3:end); else args=cell(1,0); end    % to work in all cases
        source_is_file=true;
        source_arg_is_filename=true;
    else
        data_source=[]; args=[]; source_is_file=[]; sqw_type=[]; ndims=[]; source_arg_is_filename=[];
    end
    return
    
elseif nargin>=2 && isstruct(varargin{2}) && isfield(varargin{2},'keyword') && strcmp(varargin{2}(1).keyword,'$file_data')
    % Already checked that the files are OK if got this far
    data_source=varargin{2};   % ignore first argument, which by definition is a dummy in this case
    if nargin>=3, args=varargin(3:end); else args=cell(1,0); end    % to work in all cases
    source_is_file=true;
    sqw_type=true(size(data_source));
    ndims=zeros(size(data_source));
    for i=1:numel(data_source)
        sqw_type(i)=data_source(i).sqw_type;
        ndims(i)=data_source(i).ndims;
    end
    source_arg_is_filename=false;
    mess='';
    
else
    % Assume that the sqw object is the data source
    data_source=varargin{1};    % should be efficient as just passes a pointer
    if nargin>=2, args=varargin(2:end); else args=cell(1,0); end    % to work in all cases
    source_is_file=false;
    sqw_type=true(size(data_source));
    ndims=zeros(size(data_source));
    for i=1:numel(data_source)
        sqw_type(i)=is_sqw_type(data_source(i));
        ndims(i)=dimensions(data_source(i));
    end
    source_arg_is_filename=false;
    mess='';

end
