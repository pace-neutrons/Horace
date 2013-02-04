function varargout = head (varargin)
% Display a summary of an sqw object or file containing sqw information.
% 
%   >> head(w)              % Summary for object (or array of objects)
%   >> head(sqw,filename)   % Summary for named file (or array of names)
%
% To return header information in a structure, without displaying to screen:
%
%   >> h=head(...)          % Fetch principal header information
%   >> h=head(...,'-full')  % Fetch full header information
%
%
% The facility to get head information from file(s) is included for completeness, but
% more usually you would use the function:
%   >> head_horace(filename)
%   >> h=head_horace(filename)
%   >> h=head_horace(filename,'-full')
%
%
% Input:
% -----
%   w           sqw object or array of sqw objects
%       *OR*
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = head(sqw,'c:\temp\my_file.sqw')
%
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Optional keyword:
%   '-full'     Keyword option; if present, then returns all header and the
%              detecetor information. In fact, it returns the full data structure
%              except for the signal, error and pixel arrays.
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:});
if ~isempty(mess), error(mess); end

% Perform operations
% ------------------
nout=w.nargout_req;
nw=numel(w.data);

% Check input arguments
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

if w.source_is_file
    for i=1:nw
        [h.main_header,h.header,h.detpar,h.data,mess,position,npixtot]=get_sqw (w.data{i},'-h');
        if ~isempty(mess); error(mess); end
        if nout==0
            if w.sqw_type(i)
                sqw_display_single (h,npixtot,'a')
            else
                npixtot=1;      % *** MUST MAKE GET_SQW RETURN NPIXTOT IF 'b+' TYPE
                sqw_display_single (h,npixtot,'b+')
            end
        else
            if nw==1
                if w.sqw_type(i) && hfull
                    hout=h;
                else
                    hout=h.data;
                end
            else
                if i==1, hout=cell(size(w.data)); end
                if w.sqw_type(i) && hfull
                    hout{i}=h;
                else
                    hout{i}=h.data;
                end
            end
        end
    end
else
    if nout==0
        for i=1:nw
            display(w.data(i))
        end
    else
        for i=1:nw
            if is_sqw_type(w.data(i)) && hfull
                h=struct(w.data(i));
                h.data=rmfield(h.data,{'s','e','npix','pix'});
            else
                h=rmfield(w.data(i).data,{'s','e','npix'});
                if isfield(h,'pix'), h=rmfield(h,'pix'); end    % if sqw type, then remove pix array
                if ~is_sqw_type(w.data(i))
                    if isfield(h,'urange'), h=rmfield(h,'urange'); end  % if, for some reason, there is a urange field, remove it.
                end
            end
            if nw==1
                hout=h;
            else
                if i==1, hout=cell(size(w.data)); end
                hout{i}=h;
            end
        end
    end
end

if nout>0
    argout{1}=hout;
else
    argout={};
end

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
