function [ok, mess, iline_err, doc_out] = parse_doc_section (cstr, S)
% Parse meta documentation
%
%   >> [ok, mess, iline_err, doc_out] = parse_doc_section (cstr, S)
%
% Input:
% ------
%   cstr    Cell array of strings with the new documentation to be parsed
%          in this function. Each must be valid block start or end line,
%          keyword/value line, substitution name for a cell array, or a
%          comment line i.e. begin with '%'. Assumed to have been trimmed
%          of leading and trailing whitespace and to be non-empty.
%
%   S       Structure whose fields are the names of variables and their
%          values. Fields can be:
%               - string
%               - cell array of strings (column vector)
%               - logical true or false (retain value for blocks)
%
% Output:
% -------
%   ok      If all OK, then true; otherwise false
%
%   mess    Error message if not OK; empty if all OK
%
%   iline_err   Line index in cstr at which the error occured.
%           - [] if ok
%           - scalar if single identifiable line
%           - array if several lines
%           - 0  if the problem is not identifiable with a single line
%
%   doc_out Cellarray of strings with newly parsed documentation (row vector)


% Initialise output
doc_out = {};

% Resolve S:
%   substr  Structure whose fields contain strings.
%           Each field name is a substitution name e.g. substr.mynam
%           contains the string that will replace every occurence of <mynam>
%           in cstr.
%   subcell Structure whose fields contain cellarrays of strings.
%           Each field name is a substitution name e.g. substr.mynam
%           contains the cell array of strings that will replace
%           every occurence of <mynam> in cstr. It is required that each
%           string in the cell array begins with '%' and is assumed trimmed.
%   block   Structure with fields corresponding to sections marked by
%           % <nam:>   and ending with  % <nam/end:> (optionally without
%           the leading % sign). The value of the field is 0 or 1 corresponding
%           to skipping or retaining the section
Snam=fieldnames(S);
[substr,subcell,block]=Ssplit(S);

% Split substr and subcell into a more useful forms
substrnam=fieldnames(substr);
substrnam_bra=cell(size(substrnam));
for i=1:numel(substrnam)
    substrnam_bra{i}=['<',substrnam{i},'>'];
end
substrval=struct2cell(substr);

subcellnam=fieldnames(subcell);
subcellnam_bra=cell(size(subcellnam));
for i=1:numel(subcellnam)
    subcellnam_bra{i}=['<',subcellnam{i},'>'];
end
subcellval=struct2cell(subcell);


main_block='$main';
storing=true;
state=blockobj([],'add',main_block,storing);

% Find keyword and logical block lines, and determine if a line is to be buffered
nstr=numel(cstr);
for i=1:nstr
    iline_err=i;
    [ok,mess,var,iskey,isblock,isdcom,issub,ismcom,argstr,isend] = parse_line (cstr{i});
    if ~ok, return, end
    if isblock
        % Block name. As part of checks, even if we are not reading the
        % current block (so the block name value may be undefined) we
        % check that the block beginning and end is actually defined
        % properly
        if strcmpi(var,blockobj(state,'current')) && isend
            % End of current block
            state=blockobj(state,'remove');         % move up to the parent block
            storing=blockobj(state,'storing');      % update storing status
        elseif ~isend
            % Start of new block
            if storing
                if isfield(block,var)
                    storing=block.(var);
                    state=blockobj(state,'add',var,storing);
                else
                    ok=false;
                    mess=['Unrecognised block name ''',var,''''];
                    return
                end
            else
                state=blockobj(state,'add',var,storing);
            end
        else
            ok=false;
            mess=['Block end for ''',var,''' does not match current block ''',blockobj(state,'current'),''''];
            return
        end
    elseif iskey
        % Keyword line
        % We require that any substitutions are strings, not cell arrays. Check only
        % if storing, as substitutions may not be defined for blocks that are not being parsed.
        if strcmpi(var,'file') && ~isend
            if numel(argstr)<1
                ok=false;
                mess='Must give name of file to be read on the line';
                return
            end
            if storing
                % Resolve any string substitutions
                [ok,mess,argstr]=resolve(argstr,substrnam_bra,substrval);
                if ~ok, return, end
                args=argstr;
                for j=1:numel(args)
                    % Substitute strings as variables, if can
                    % Special case of an entry args{j} == ''''; replace with ''
                    if strcmp(args{j},'''''')
                        args{j}='';
                    else
                        ix=find(strcmpi(args{j},Snam),1);
                        if ~isempty(ix)
                            args{ix}=S.(args{j});
                        end
                    end
                end
                % If the file name is empty, then skip
                if ~isempty(args{1})
                    [ok,mess,lstruct]=read_file(args{1});
                    if ~ok, return, end
                    is_topfile = false;
                    doc_filter = {};
                    [ok, mess, doc_new] = parse_doc (lstruct, args(2:end), S,...
                        is_topfile, doc_filter);
                    if ~ok, return, end
                    doc_out=[doc_out,doc_new];
                end
            end
        else
            ok=false;
            mess=['Unrecognised keyword ''',var,''''];
            return
        end
    elseif issub
        % Line substitution - the line has form '<var_name>', and we demand
        % that var_name is a cellstr
        if storing
            tf=strcmp(var,subcellnam);
            if any(tf)
                tmp=subcellval(tf);
                doc_out=[doc_out,make_matlab_comment(tmp{1})'];
            else
                ok=false;
                mess='Substitution must be a cell array of strings in line:';
                return
            end
        end
    elseif ismcom
        % Matlab comment line
        if storing
            tmp=strtrim(cstr{i}(2:end));
            if length(tmp)>2 && tmp(1)=='<' && tmp(end)=='>' &&...
                    isvarname(tmp(2:end-1)) && any(strcmp(tmp(2:end-1),subcellnam))
                % Catch case of possible cellstr substitution i.e. '% <var_name>'
                tf=strcmp(tmp(2:end-1),subcellnam);
                tmp=subcellval(tf);
                doc_out=[doc_out,make_matlab_comment(tmp{1})'];
            else
                if storing
                    [ok,mess,line]=resolve(cstr{i},substrnam_bra,substrval);
                    if ~ok, return, end
                    doc_out=[doc_out,{line}];
                end
            end
        end
    elseif isdcom
        % docify comment - do nothing
    else
        error('Logic error in docify application - see developers')
    end
end

% Check that blocks are consistent
if ~strcmpi(main_block,blockobj(state,'current'))
    ok=false; iline_err=0;
    mess='Block start and end(s) are inconsistent';
    return
end

% All OK if got here
iline_err=[];

%--------------------------------------------------------------------------------------
function cstr_out = make_matlab_comment (cstr)
% Make a cell array of strings valid Matlab comments by prepending '% ' where necessary
% and turning into a column vector
cstr_out=cstr(:);
for j=1:numel(cstr_out)
    if cstr_out{j}(1)~='%'
        cstr_out{j}=['% ',cstr_out{j}];     % prepend '% ' if not a Matlab comment
    end
end
