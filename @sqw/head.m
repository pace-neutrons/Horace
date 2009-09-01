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
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)


[data_source, args, source_is_file, sqw_type, ndims] = parse_data_source (varargin{:});
if ~isempty(args)
    error('Check number of arguments')
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

if nargout~=0
    % In this case, there is at most only one output argument
    if source_is_file
        varargout{1}={h};    % output from cut must be cell array
    else
        varargout{1}=h;
    end
end
