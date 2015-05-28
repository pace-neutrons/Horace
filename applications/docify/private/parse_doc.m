function [ok,mess,docnew,no_change]=parse_doc(source,doc,S,args)
% Parse meta documentation source (file or cell array of strings)
%
%   >> [ok,mess,source_out]=parse_doc(source)
%   >> [ok,mess,docnew]=parse_doc(source,doc,S,args)
%
% Input:
% ------
%   source  *EITHER*
%           Name of file that contains meta-documentation
%           *OR*
%           Cell array of strings containing meta-documentation (row vector)
%
%   doc     Cellarray of strings that contain the accumulated parsed
%           documentation (row vector)
%
%   S
%
%   args
%
% Output:
% -------
%   ok      =true if all OK, =false if not
%
%   mess    Message. It may have contents even if OK==true, in which case
%           it is purely informational or warning.
%
%   docnew  Cell array of strings containing output documentation
%           or, in the case of top level call, the full function with the
%           meta-documentation fully parsed.
%
%   no_change   =true if 
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
if nargin==1
    top=true;
    doc={};
    S=struct;
    args={};
elseif nargin>1
    top=false;
else
    error('Check number of input arguments');
end

% Initialise output
ok=true;
mess='';
docnew=doc;
no_change=true;

% Get data from source
if isstring(source) && ~isempty(source)
    [file_full,ok,mess]=translate_read(source);
    if ok
        cstr0=read_text(file_full);
    else
        return
    end
elseif iscellstr(source)
    cstr0=source;
else
    ok=false;
    mess='Unrecognised data source (must be text file or cell array of strings)';
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
if ~top
    ilo=1;
    ihi=nstr;
else
    iscomment=strncmp(cstr,'%',1);
    ilo=find(iscomment,1);
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
        mess='No comment block';
        return
    end
end

% Find doc keywords
idef=[]; ibeg=[]; iend=[];
for i=ilo:ihi
    [var,iskey]=parse_key(cstr{i});
    if iskey
        if strcmpi(var,'doc_def')
            idef=[idef,i];
        elseif strcmpi(var,'doc_beg')
            ibeg=[ibeg,i];
        elseif strcmpi(var,'doc_end')
            iend=[iend,i];
        end
    end
end

if ~top
    if isempty(ibeg), ibeg=0; end       % assume at beginning
    if isempty(iend), iend=nstr+1; end  % assume at end
end

% Get doc definition and doc section
if isscalar(ibeg) && isscalar(iend) && ibeg<=iend
    if isempty(idef) || (isscalar(idef) && idef<ibeg)
        [ok,mess,docnew] = parse_doc_internal (cstr, idef, ibeg, iend, doc, S, args);
        if ~ok
            return
        end
    else
        ok=false;
        mess='Meta documentation block must be <#doc_beg:>...<#doc_end:> or <#doc_def:>...<#doc_beg:>...<#doc_end:>';
    end
elseif ~(isempty(idef) && isempty(ibeg) && isempty(iend))
    ok=false;
    mess='Meta documentation block must be <#doc_beg:>...<#doc_end:> or <#doc_def:>...<#doc_beg:>...<#doc_end:>';
end

% If top call, then wrap
if top
    if ~isempty(docnew)
        % Keep everything except those lines in the first comment block that
        % precede the meta-documentation block. The resolved documentation
        % is written in their place, followed by a blank line. The meta-
        % documentation is retained. Repeated running of the function does
        % not change the output (the blank line that was inserted is compressed
        % away, and the resolved documentation discarded)
        if isempty(idef)
            istart=ibeg;
        else
            istart=idef;
        end
        docnew=[cstr0(1:ind(ilo)-1),docnew,{''},cstr0(ind(istart):end)];
        no_change=false;
    else
        docnew=cstr0;   % no change
        no_change=true;
    end
end

%-------------------------------------------------------------------------------
function [ok,mess,doc] = parse_doc_internal (cstr, idef, ibeg, iend, doc, S, args)
% Parse meta documentation after having checked that all input is OK

% Get doc definitions
if ~isempty(idef)
    if ~all(strncmp(cstr(idef+1:ibeg-1),'%',1))
        ok=false;
        mess='All lines in a documentation definition block must be comment lines';
        return
    end
    [Snew,ok,mess]=parse_doc_definitions(cstr(idef+1:ibeg-1),args);
    if ok
        Snew=mergestruct(Snew,S);
    else
        return
    end
else
    Snew=S;
end

% Get new documentation
[ok,mess,doc] = parse_doc_section (cstr(ibeg+1:iend-1), doc, Snew);
