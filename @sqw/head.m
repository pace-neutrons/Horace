function varargout = head(varargin)
% Display a summary of a file containing sqw information
% 
%   >> head(sqw,file)
%   >> h=head(sqw,file)
%
% Need to give first argument as an sqw object, can simply create a dummy object with a call to sqw
%    e.g. >> head(sqw,'c:\temp\my_file.sqw')
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

%This function will do some weird shit if we try to make it account for the
%existence of arrays of objects. So instead we will throw an error message
%if the user tries to use it on an array of sqw:

if isa(varargin{1},'sqw') && numel(varargin{1})>1
    error('head cannot be used for arrays of objects, only single objects and files');
end

if nargin>1
    try
        [sqw_type, nd, data_source_1, mess] = is_sqw_type_file(varargin{:});
    catch
        error('Error reading sqw file - ensure that head called with a dummy sqw object as the 1st argument, and a file string as the 2nd');
    end
    [data_source, args, source_is_file, sqw_type, ndims] = parse_data_source (varargin{1},data_source_1);
    if ~isempty(args)
        error('Check number of arguments')
    end
else
    [data_source, args, source_is_file, sqw_type, ndims] = parse_data_source (varargin{:});
end


% Display data as the requested object i.e. if requested the data to be treated as dnd-type, then give
% the header information as if it was read from sqw file as dnd (if data source is file), or performed dnd(data_source)
% if data_source is a sqw object.

if source_is_file
    [h.main_header,h.header,h.detpar,h.data,mess,position,npixtot,type]=get_sqw (data_source,'-h');
    if ~isempty(mess); error(mess); end
    if sqw_type
        sqw_display_single (h,npixtot,'a')
    else
        npixtot=1;      % *** MUST MAKE GET_SQW RETURN NPIXTOT IF 'b+' TYPE
        sqw_display_single (h,npixtot,'b+')
        h=h.data;
        if isfield(h,'urange'), h=rmfield(h,'urange'); end      % if file was dnd-type then this field will not be present anyway
    end
else
    display(data_source)
    if nargout>0
        if is_sqw_type(data_source)
            h=struct(data_source);
            h.data=rmfield(h.data,{'s','e','npix','pix'});
        else
            h=data_source.data;
            h=rmfield(h,{'s','e','npix','pix'});
        end
    end
end

% Package output: if file data source then package all output arguments as a single cell array, as the output
% will be unpacked by control routine that called this method. If object data source, then package as conventional
% varargout

% if nargout~=0
%     % In this case, there is at most only one output argument
%     if source_is_file
%         varargout{1}={h};    % output from cut must be cell array
%     else
%         varargout{1}=h;
%     end
% end

if nargout~=0
    if source_is_file && eixt(data_source_1,'var') && isfield(data_source_1,'keyword') && strcmp(data_source_1.keyword,'$file_data')
        varargout{1}=h;
    elseif source_is_file
        varargout{1}={h};
    else
        varargout{1}=h;
    end
end