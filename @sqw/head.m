function varargout = head(varargin)
% Display a summary of a file containing sqw information
% 
%   >> head(sqw,file)       % display header information
%   >> h=head(sqw,file)     % put header information into a structure as well as display
%
% Gives the same information as display for an sqw object.
%
% Need to give first argument as an sqw object to enforce a call to this function.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> head(sqw,'c:\temp\my_file.sqw')
%
% Input:
% -----
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

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


% Display data as the requested object i.e. if requested the data to be treated as dnd-type, then give
% the header information as if it was read from sqw file as dnd (if data source is file), or performed dnd(data_source)
% if data_source is a sqw object.

if source_is_file
    for i=1:numel(data_source)
        [h.main_header,h.header,h.detpar,h.data,mess,position,npixtot,type]=get_sqw (data_source(i).filename,'-h');
        if ~isempty(mess); error(mess); end
        if sqw_type(i)
            sqw_display_single (h,npixtot,'a')
        else
            npixtot=1;      % *** MUST MAKE GET_SQW RETURN NPIXTOT IF 'b+' TYPE
            sqw_display_single (h,npixtot,'b+')
            if isfield(h.data,'urange'), h.data=rmfield(h.data,'urange'); end      % if file was dnd-type then this field will not be present anyway
        end
        if nargout>0
            if numel(data_source)==1
                hout=h.data;    % return a structure
            else
                if i==1, hout=cell(size(data_source)); end
                hout{i}=h.data;
            end
        end
    end
else
    % display(data_source)    % will say every object is sqw object if an array - cannot tell if e.g. d2d that came via d2d/display
    for i=1:numel(data_source)
        display(data_source(i))
    end
    if nargout>0
        for i=1:numel(data_source)
            if is_sqw_type(data_source(i))
                h=rmfield(data_source(i).data,{'s','e','npix','pix'});
            else
                h=rmfield(data_source(i).data,{'s','e','npix'});
                if isfield(h,'pix'), h=rmfield(h,'pix'); end   % if, for some reason, there is a pix field, remove it.
                if isfield(h,'urange'), h=rmfield(h,'urange'); end  % if, for some reason, there is a urange field, remove it.
            end
            if numel(data_source)==1
                hout=h;    % return a structure
            else
                if i==1, hout=cell(size(data_source)); end
                hout{i}=h;
            end
        end
    end
end

% Package output: if file data source structure then package all output arguments as a single cell array, as the output
% will be unpacked by control routine that called this method. If object data source or file name, then package as conventional
% varargout

% In this case, there is only one output argument
if nargout>0
    if source_is_file && ~source_arg_is_filename
        varargout{1}={hout};
    else
        varargout{1}=hout;
    end
end
