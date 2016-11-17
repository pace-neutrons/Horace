function [ok,mess,doc_out,varargout]=parse_doc(flname,varargin)
% Parse meta documentation source (file or cell array of strings)
%
% To docify an .m file:
%   >> [ok, mess, source, changed] = parse_doc (flname, doc_filter)
%
% As used in recursive calls to resolve documentation files:
%   >> [ok, mess, doc_out] = parse_doc (flname, args, S, doc)
%
% Input:
% ------
%   flname  Name of file that contains meta-documentation if top level call
%
% If parsing .m file:
%   doc_filter  Cell array of strings with acceptable filter keywords
%          on the <#doc_beg:> line. If non-empty, only if one of the
%          keywords appears on the line will the documnetation be
%          included
%
% If parsing a documentation file:
%   args    Cell array of arguments (each must be a string or cell array of
%          strings or logical scalar (or 0 or 1)
%
%   S       Structure whose fields are the names of variables and their
%          values. Fields can be:
%               - string
%               - cell array of strings (column vector)
%               - logical true or false (retain value for blocks)
%
%   doc     Cellarray of strings that contain the accumulated parsed
%           documentation so far (row vector)
%
% Output:
% -------
%   ok      =true if all OK, =false if not
%
%   mess    Message. It may have contents even if OK==true, in which case
%          it is purely informational or warning.
%
% If parsing .m file:
%   source  Source code with meta-documentation replacing that in the
%          original file.
%
%   changed True if meta-documentation parsing changes the source; false
%           otherwise
%
% If parsing a documentation file:
%   doc_out Cell array of strings containing output documentation
%          or, in the case of top level call, the full function with the
%          meta-documentation fully parsed.
%
%
% Meta documentation has the form:
%
% Main file:
% ----------
% First occurence in the first documentation block of the block:
%
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%
% or, more generally, first occurence of the block:
%
%   % <#doc_def:>
%   %   :
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%
% Called files:
% -------------
%
%   %   :
%
% or, more generally (no leading lines):
%
%   % <#doc_def:>
%   %   :
%   % <#doc_beg:>
%   %   :
%
% Can also have either of the forms for the main file


% Determine if top level call
if nargin==2
    top=true;
    doc_filter=varargin{1};
    args={};
    S=struct;
    % Initialise output
    return_changed=(nargout==4);
    doc_out={};
    if return_changed, varargout{1}=false; end
elseif nargin==4
    top=false;
    args=varargin{1};
    S=varargin{2};
    doc=varargin{3};
    % Initialise output
    return_changed=false;
    doc_out=doc;
else
    error('Check number of input arguments - see developers');
end

% Initialise output

% Get data from source
[fname_full,ok,mess]=translate_read(flname);
if ok
    [cstr0,ok,mess] = textcell (fname_full);
    if ~ok, return, end
else
    return
end

% Trim and remove blank lines
[cstr,~,nonempty]=str_trim_cellstr(cstr0);
ind=find(nonempty);
nstr=numel(cstr);
if nstr==0
    return
end

% If top level, then find first block of documentation
% *** should check that there is only the function definition before the first block
if top
    iscomment=strncmp(cstr,'%',1);
    ilo=find(iscomment,1);
    if ilo==1
        % There is a comment block before any executable code - not
        % currently parsed by this function
        ok=false;
        mess = make_message (fname_full,...
            'Currently cannot parse code with a leading comment block');
        return
    end
    if ~isempty(ilo)
        if ilo<nstr
            ihi=find(~iscomment(ilo+1:end),1);
            if ~isempty(ihi)
                ihi=ihi+ilo-1;
            else
                ihi=nstr;
            end
        else
            ihi=ilo;
        end
    else
        doc_out=cstr0;
        return
    end
else
    ilo=1;
    ihi=nstr;
end

% Find doc keywords
idef=[]; ibeg=[]; iend=[];
for i=ilo:ihi
    [var,iskey]=parse_line(cstr{i});
    if iskey
        if strcmpi(var,'doc_def')
            if ~isempty(idef)
                mess='Meta documentation block can contain only one instance of <#doc_def:>';
                break
            end
            idef=i;
        elseif strcmpi(var,'doc_beg')
            if ~isempty(ibeg)
                mess='Meta documentation block can contain only one instance of <#doc_beg:>';
                break
            end
            ibeg=i;
        elseif strcmpi(var,'doc_end')
            if ~isempty(iend)
                mess='Meta documentation block can contain only one instance of <#doc_end:>';
                break
            end
            iend=i;
        end
    end
end
if ~ok
    mess = make_message (fname_full,mess);
    return
end
if ~top
    if isempty(ibeg), ibeg=0; end       % assume at beginning
    if isempty(iend), iend=nstr+1; end  % assume at end
end

% Parse documentation
if isscalar(ibeg) && isscalar(iend) && ibeg<=iend
    % Accumulate addition definitions, if any
    if isscalar(idef) && idef<ibeg
        [Snew,ok,mess]=parse_doc_definitions(cstr(idef+1:ibeg-1),args,S);
        if ~ok
            mess = make_message (fname_full,mess);
            return
        end
    elseif isempty(idef)
        Snew=S;
    else
        ok=false;
        mess = make_message (fname_full,...
            'Meta documentation block must be <#doc_beg:>...<#doc_end:> or <#doc_def:>...<#doc_beg:>...<#doc_end:>');
        return
    end
    % Get new documentation
    [doc_out, ok, mess] = parse_doc_section (cstr(ibeg+1:iend-1), Snew, doc_out);
    if ~ok
        mess = make_message (fname_full,mess);
        return
    end
    % If top call, then must replace the documentation
    if top
        % Keep everything except those lines in the first comment block that
        % precede the meta-documentation block. If not empty, the resolved
        % documentation is written in their place, followed by a blank line. The
        % meta-documentation is retained. Repeated running of the function does
        % not change the output (the blank line that was inserted is compressed
        % away, and the resolved documentation discarded)
        if isempty(idef)
            istart=ibeg;
        else
            istart=idef;
        end
        if ~isempty(doc_out)
            doc_out=[cstr0(1:ind(ilo)-1),doc_out,{''},cstr0(ind(istart):end)];
        else
            doc_out=[cstr0(1:ind(ilo)-1),cstr0(ind(istart):end)];
        end
        if return_changed
            if numel(doc_out)==numel(cstr0) && all(strcmp(doc_out,cstr0))
                varargout{1}=false;
            else
                varargout{1}=true;
            end
        end
    end
elseif ~(isempty(idef) && isempty(ibeg) && isempty(iend))
    ok=false;
    mess = make_message (fname_full,...
        'Meta documentation block must be <#doc_beg:>...<#doc_end:> or <#doc_def:>...<#doc_beg:>...<#doc_end:>');
    return
end

%-------------------------------------------------------------------------------
function mess = make_message (filename,mess_in)
[~,mess]=str_make_cellstr(['In file: ',filename],mess_in);
