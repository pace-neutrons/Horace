function varargout = head (varargin)
% Display a summary of an sqw object or file containing sqw information.
%
%   >> head(w)              % Display summary for object (or array of objects)
%   >> head(sqw,filename)   % Display summary for named file (or array of names)
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
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)


% Parse input
% -----------
[w, args, mess] = horace_function_parse_input (nargout,varargin{:},'$obj_and_file_ok');
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
    if hfull
        opt = {'-full'};
    else
        opt ={};
    end
    if nout==0
        head_horace(w.loaders_list,opt{:});
    else
        hout = head_horace(w.loaders_list,opt{:});
        if ~iscell(hout)
            hout = {hout};
        end
        if iscell(hout{1}) && numel(hout)== 1
            hout = hout{1};
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
                h=w.data(i);
                h.data=rmfield(h.data.to_struct(),{'s','e','npix','pix'});
            else
                %w.data(i).
                h=rmfield(w.data(i).data.to_struct(),{'s','e','npix'});
                if is_sqw_type(w.data(i))
                    h=rmfield(h,'pix');
                else
                    if isfield(h,'urange'), h=rmfield(h,'urange'); end  % if, for some reason, there is a urange field, remove it.
                end
            end
            if nw==1
                hout={h};
            else
                if i==1, hout=cell(size(w.data)); end
                hout{i}=h;
            end
        end
    end
end

if nout>0
    argout = hout;
else
    argout={};
end

% Package output arguments
% ------------------------
[varargout,mess]=horace_function_pack_output(w,argout{:});
if ~isempty(mess), error(mess), end
