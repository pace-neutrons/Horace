function [ok, mess, idef, ibeg, iend] = parse_doc_blocks (cstr, is_topfile, doc_filter)
% Find the locations of meta documentation blocks in a cell array of character strings
%
%   >> [ok, mess, idef, ibeg, iend] = parse_doc_blocks (cstr, is_topfile, doc_filter)
%
% Input:
% ------
%   cstr        Cell array of character strings. Assumed to be non-empty and
%              trimmed of leading and trailing whitespace.
%
%   is_topfile  True if cstr is from the top level mfile, false otherwise
%          If true, then if there must be an explicit doc_beg line for
%          there to be meta documentation
%
%   doc_filter  Cell array of strings with acceptable filter keywords
%              on the <#doc_beg:> line. If non-empty, only if one of the
%              keywords appears on the line will the documentation be
%              included
%
% Output:
% -------
%   ok          True if all OK, flase if not
%
%   mess        Error message if not OK; '' if OK
%
%   idef        Index of doc_def line (array if more than one block)
%              idef(1) can be =0
%              Set to ibeg where there is no definition block
%
%   ibeg        Index of doc_beg line (array if more than one block)
%              Note ibeg(1) can be =0
%
%   iend        Index of doc_end line (array if more than one block)
%              Always true that iend>=ibeg+1. Note iend(end) can be numel(cstr)+1
%
% Notes
%   - If no documentation block was found then numel(idef)=numel(ibeg)=numel(iend)=0
%
%   - Blocks may have no lines to parse i.e. iend(i)==ibeg(i)+1. We do not remove
%    these, however, because this is significant in the top level m-file: it
%    will force leading lines that are not part of the meta documentation to be
%    removed. Furthermore, there may be definitions that have been given for that
%    block but which are erroneous; we do not want to presume that they are valid
%    and so we want to ensure that all contents of cstr are parsed in later routines.
%
%
% Form of meta documentation file:
% --------------------------------
% Simplest form; all contents are meta documentation:
%
%   %   :
%
% Leading comment lines that will be ignored, and assumed 'missing' end:
%   %   :
%   % <#doc_beg:>
%   %   :
%
% The same with a definition section:
%   %   :
%   % <#doc_def:>
%   %   :
%   % <#doc_beg:>
%   %   :
%
% Any number of blocks, spaced with comments that will be ignored, with assumed
% 'missing' end at the end of the block, if necessary.
%
%   %   :
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%   %   :
%
% or
%
%   %   :
%   % <#doc_def:>
%   %   :
%   % <#doc_beg:>
%   %   :
%   % <#doc_end:>
%   %   :


ok = true;
mess = '';

% Trivial case of no lines
if numel(cstr)==0
    idef=[]; ibeg=[]; iend=[];
    return
end

% Lines to parse
[~,~,var,iskey,~,~,~,~,doc_keys] = cellfun(@(x)parse_line(x), cstr, 'UniformOutput', false);

iskey = cell2mat(iskey);

idef = find(strcmpi(var,'doc_def') & iskey);
ibeg = find(strcmpi(var,'doc_beg') & iskey);
iend = find(strcmpi(var,'doc_end') & iskey);

% Must have sequence of beg-end or def-beg-end blocks. The special cases are:
% (1) None of the three keywords is present: this is equivalent to doc_beg
%    at the top of the file and doc_end at the end of the file;
% (2) There is a 'missing' final doc_end, which is assumed to come after the
%    end of the file.
% The exception is if the lines have come from the top level m-file which is
% being parsed. In that instance, the first case means that there is no meta
% documentation, and the secon case is not permitted: we demand an explicit
% doc_end
if isempty(idef) && isempty(ibeg) && isempty(iend)
    % None of doc_def, doc_beg, doc_end
    if is_topfile
        % Lines assumed to be pure comment lines
        idef=[]; ibeg=[]; iend=[];
    else
        % Assume all the lines are meta documentation
        idef=0; ibeg=0; iend=numel(cstr)+1;
    end
    
elseif numel(ibeg)>=1 && (...
        (numel(iend)==numel(ibeg) && all(iend-ibeg>0)) ||...
        (~is_topfile && numel(iend)==numel(ibeg)-1 && all([iend,numel(cstr)+1]-ibeg>0)))
    % Distinct doc_beg...doc_end blocks
    nblock = numel(ibeg);

    % Add 'missing' iend if necessary
    if numel(iend)<nblock
        iend=[iend,numel(cstr)+1];
    end
    
    % Check definition statements are consistent
    if ~isempty(idef)
        ind = lower_index (ibeg,idef);      % block index to which doc_def statement must belong
        ind_prev = upper_index (iend,idef); % previous block index
        if ind(end)<=nblock && all(ind==ind_prev+1)
            % doc_defs appear in adjacent doc_end...doc_beg and last doc_def appears before last doc_beg
            tmp = ibeg;
            tmp(ind) = idef;
            idef = tmp;
        else
            ok=false;
            mess=['Meta documentation block does not consist of independent'...
                '<#doc_def:>...<#doc_beg:>...<#doc_end:> blocks'];
            idef=[]; ibeg=[]; iend=[];
        end
    else
        idef=ibeg;
    end
    
    % Filter out blocks
    if ok && ~isempty(doc_filter) && numel(ibeg)>0
        keep = true(size(ibeg));
        for i=1:numel(ibeg)
            if ibeg(i)>0 && ~any(ismember(doc_keys{ibeg(i)},doc_filter))
                keep(i) = false;
            end
        end
        idef = idef(keep);
        ibeg = ibeg(keep);
        iend = iend(keep);
    end
    
else
    ok=false;
    mess=['Meta documentation block does not consist of independent'...
        '<#doc_def:>...<#doc_beg:>...<#doc_end:> blocks'];
    idef=[]; ibeg=[]; iend=[];
end
