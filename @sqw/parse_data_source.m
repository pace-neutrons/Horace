function [data_source, args, source_is_file, sqw_type, ndims] = parse_data_source (varargin)
% Resolve input arguments to sqw methods where a file may be the source of data.
%
%   >> [data_source, args, source_is_file, sqw_type, ndims, args] = parse_data_source (sqw_object, varargin)
%   >> [data_source, args, source_is_file, sqw_type, ndims, args] = parse_data_source (dummy_sqw_object, data_source_structure, varargin)
%
%   The convention is that if the function has a file as the source of data, then the first argument is
%   a dummy sqw object, and the second argument is a structure with fields:
%       data_source.keyword     '$file_data'
%       data_source.file        Input file name
%       data_source.sqw_type    How to read data file: =true if sqw_type, =false if dnd_type
%       data_source.ndims       Dimensions of the sqw object
%   The file is assumed already to have been checked to be valid, and the other information correct.
%
% NOTE:
%   data_source_struct.sqw_type is not necessarily the same as the type of data in the file.
%  if sqw_type data in the file, we may still set the flag so that it is read as dnd-type data.


% Original author: T.G.Perring
%
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)


% Parse input arguments
% ---------------------
% Determine if data source is sqw object or file
if nargin>=2 && isstruct(varargin{2}) && isfield(varargin{2},'keyword') && strcmp(varargin{2}.keyword,'$file_data')
    % Already checked that the file is OK if got this far
    data_source=varargin{2}.file;   % override input variable, which by definition is a dummy in this case
    args=varargin(3:end);
    source_is_file=true;
    sqw_type=varargin{2}.sqw_type;
    ndims=varargin{2}.ndims;
else
    data_source=varargin{1};        % should be efficient as just passes a pointer
    args=varargin(2:end);
    source_is_file=false;
    sqw_type=is_sqw_type(data_source);
    ndims=dimensions(data_source);
end
