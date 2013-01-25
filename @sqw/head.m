function varargout = head(varargin)
% Display a summary of an sqw object or file containing sqw information.
% 
%   >> head(w)              % display header information for sqw object (or array of objects)
%   >> head(sqw,filename)   % display header information for name sqw file (or array of names)
%
%   >> h=head(...)          % Put header information into a structure; do not display
%   >> h=head(...,'-full')  % Put full header information into a structure
%
% Lists to the screen the same information as display method for an sqw object.
%
% The facility to get head information from file(s) is included for completenes, but
% more usually you would use the function:
%   >> head_horace(filename)
%   >> h=head_horace(filename)
%   >> h=head_horace(filename,'-full')
%
% If you use this function to get head information from file data source(s), then
% you need to give first argument as an sqw object to enforce a call to this
% function. You can simply create a dummy object with a call to sqw:
%    e.g. >> head(sqw,'c:\temp\my_file.sqw')
%
% Input:
% -----
%   w           sqw object or array of sqw objects
%       *OR*
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Optional keyword:
%   '-full'     Puts full header information into a structure. This includes the
%               information for each contributing data file and detector information.
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% NOTE: In addition to the functionality documented above, the function also takes
%       a data_source structure created from an earlier call to parse_data_source

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% If data source is a filename, then must ensure that matches sqw type
% Recall this function is used by d0d, d1d,... as a gateway routine, so if
% data_source is structure it may require non sqw type data to be read. 
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
hfull=false;
if ~isempty(args)
    sz=size(args{1});
    if numel(args)==1 && ischar(args{1}) && ~isempty(args) && numel(sz)==2 && sz(1)==1 &&...
            strncmpi(args{1},'-full',numel(args{1}))
        hfull=true;
    else
        error('Check optional input argument')
    end
end

% Display data as the requested object i.e. if requested the data to be
% treated as dnd-type, then give the header information as if it was read from
% sqw file as dnd (if data source is file), or performed dnd(data_source)
% if data_source is a sqw object.

if source_is_file
    for i=1:numel(data_source)
        [h.main_header,h.header,h.detpar,h.data,mess,position,npixtot,type]=get_sqw (data_source(i).filename,'-h');
        if ~isempty(mess); error(mess); end
        if nargout==0
            if sqw_type(i)
                sqw_display_single (h,npixtot,'a')
            else
                npixtot=1;      % *** MUST MAKE GET_SQW RETURN NPIXTOT IF 'b+' TYPE
                sqw_display_single (h,npixtot,'b+')
            end
        else
            if numel(data_source)==1
                if hfull
                    hout=h;
                else
                    hout=h.data;
                end
            else
                if i==1, hout=cell(size(data_source)); end
                if hfull
                    hout{i}=h;
                else
                    hout{i}=h.data;
                end
            end
        end
    end
else
    % display(data_source)    % will say every object is sqw object if an array - cannot tell if e.g. d2d that came via d2d/display
    if nargout==0
        for i=1:numel(data_source)
            display(data_source(i))
        end
    elseif nargout>0
        for i=1:numel(data_source)
            if is_sqw_type(data_source(i)) && hfull
                h=struct(data_source(i));
                h.data=rmfield(h.data,{'s','e','npix','pix'});
            else
                h=rmfield(data_source(i).data,{'s','e','npix'});
                if isfield(h,'pix'), h=rmfield(h,'pix'); end    % if sqw type, then remove pix array
                if ~is_sqw_type(data_source(i))
                    if isfield(h,'urange'), h=rmfield(h,'urange'); end  % if, for some reason, there is a urange field, remove it.
                end
            end
            if numel(data_source)==1
                hout=h;
            else
                if i==1, hout=cell(size(data_source)); end
                hout{i}=h;
            end
        end
    end
end

% Package output: if file data source structure then package all output
% arguments as a single cell array, as the output will be unpacked by the
% control routine that called this method. If object data source or file
% name, then package as conventional varargout.

if nargout>0
    if source_is_file && ~source_arg_is_filename
        % Input was a data_source structure, so package
        varargout{1}={hout};
    else
        % Input was was sqw object or filename, so copy each output argument to varargout.
        varargout{1}=hout;          % only one output argument in this case
        % varargout{2}= out_2 ...   % example if more than one output argument
    end
end
