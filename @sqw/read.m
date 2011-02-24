function varargout = read(varargin)
% Read sqw object from a file or array of sqw objects from a set of files
% 
%   >> w=read(sqw,file)
%
% Need to give first argument as an sqw object to enforce a call to this function.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
% Input:
% -----
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
%   file        File name, or cell array of file names. In this case, reads
%               into an array of sqw objects
%
% Output:
% -------
%   w           sqw object, or array of sqw objects if given cell array of
%               file names

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% If data source is a filename, then must ensure that matches sqw type
% Recall this function is used by d0d, d1d,... as a gateway routine, so if data_source is structure
% it may require non sqw type data to be read. 
[data_source, args, source_is_file, sqw_type, ndims, source_arg_is_filename, mess] = parse_data_source (varargin{:});
if ~isempty(mess)
    error(mess)
end
if source_arg_is_filename
    if ~all(sqw_type)
        error('Data file(s) not (all) sqw type i.e. does(do) not contain pixel information')
    end
end

% Check number of arguments
if ~isempty(args)
    error('Check number of arguments')
end

% Now read data
if source_is_file
    if all(sqw_type)
        w = sqw(data_source(1).filename);
        if numel(data_source)>1
            for i=1:numel(data_source)
                w(i)=sqw(data_source(i).filename);
            end
            w=reshape(w,size(data_source));
        end
    elseif all(~sqw_type) && all(ndims==ndims(1))
        w = sqw('$dnd',data_source(1).filename);
        if numel(data_source)>1
            for i=1:numel(data_source)
                w(i)=sqw('$dnd',data_source(i).filename);
            end
            w=reshape(w,size(data_source));
        end
    else
        error('Data files must all be sqw type, or all dnd type with same dimensionality')
    end
else
    w=data_source;  % trivial case that data_source is already valid object
end

% Package output: if file data source structure then package all output arguments as a single cell array, as the output
% will be unpacked by control routine that called this method. If object data source or file name, then package as conventional
% varargout

% In this case, there is only one output argument
if source_is_file && ~source_arg_is_filename
    varargout{1}={w};
else
    varargout{1}=w;
end
