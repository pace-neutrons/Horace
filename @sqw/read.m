function varargout = read(varargin)
% Read sqw object from a file
% 
%   >> w=read(sqw,file)
%
% Need to give first argument as an sqw object to enforce the execution of this method.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> read(sqw,'c:\temp\my_file.sqw')
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

%First must get the file input into the correct format for
%parse_data_source to deal with it:
try
    [sqw_type, nd, data_source_1, mess] = is_sqw_type_file(varargin{:});
catch
    error('Error reading sqw file - ensure that read called with a dummy sqw object as the first argument');
end
    
[data_source, args, source_is_file, sqw_type, ndims] = parse_data_source (varargin{1},data_source_1);
if ~isempty(args)
    error('Check number of arguments')
end

if source_is_file
    if sqw_type
        w = sqw(data_source);
    else
        w = sqw('$dnd',data_source);
    end
else
    w = data_source;    % trivial case that data_source is already valid object
end

% Package output: if file data source then package all output arguments as a single cell array, as the output
% will be unpacked by control routine that called this method. If object data source, then package as conventional
% varargout

% In this case, there is only one output argument
if source_is_file && isfield(data_source_1,'keyword') && strcmp(data_source_1.keyword,'$file_data')
    varargout{1}=w;
elseif source_is_file
    varargout{1}={w};
else
    varargout{1}=w;
end
