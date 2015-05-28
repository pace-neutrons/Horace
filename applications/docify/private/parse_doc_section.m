function [ok,mess,doc] = parse_doc_section (cstr, doc, S)
% Parse meta documentation
%
%   >> [ok,mess,doc] = parse_doc_section (doc, cstr, subst, block)
%
% Input:
% ------
%   doc     Cellarray of strings that contain the accumulated parsed
%           documentation.
%   cstr    Cell array of strings with the new documentation to be parsed
%           in this function. Each must be valid block start or end line,
%           keyword/value line, substitution name for a cell array, or a 
%           comment line i.e. begin with '%'. Assumed to have been trimmed
%           and non-empty.
%
% Output:
% -------
%   ok      If all OK, then true; otherwise false
%   mess    Error message if not OK; empty if all OK
%   doc     Cellarray of strings with newly parsed documentation appended


Snam=fieldnames(S);

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
%           % <nam:>   and ending with  % <nam/end:> (optinally without
%           the leading % sign). The value of the field is 0 or 1 corresponding
%           to skipping or retaining the section
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
    [var,iskey,isend,argstr,ok,mess]=parse_key(cstr{i});
    if ok   % block indicator or keyword
        if ~iskey
            var=lower(var);
            % Block name. As part of checks, even if we are not reading the
            % current block (so the block name value may be undefined) we
            % check that the block beginning and end is actually defined
            % properly
            if strcmpi(var,blockobj(state,'current')) && isend
                % End of current block
                state=blockobj(state,'remove');             % move up to the parent block
                storing=blockobj(state,'storing');      % update storing status
            elseif ~isend
                % Start of new block
                if storing
                    if isfield(block,var)
                        storing=block.(var);
                        state=blockobj(state,'add',var,storing);
                    else
                        ok=false;
                        mess=['Unrecognised block name: ''',var,''''];
                        return
                    end
                else
                    state=blockobj(state,'add',var,storing);
                end
            else
                ok=false;
                mess=['Block end for: ''',var,''' does not match current block:''',blockobj(state,'current'),''''];
                return
            end
        else
            % Keyword line
            % We require that any substitutions are strings, not cell arrays. Check only
            % if storing, as substitutions may not be defined for blocks that are not being parsed.
            if strcmpi(var,'file') && ~isend
                if numel(argstr)<1
                    ok=false;
                    mess={'Must give file name in line:',cstr{i}};
                    return
                end
                if storing
                    % Resolve any string substitutions
                    [argstr,ok,mess]=resolve(argstr,substrnam_bra,substrval);
                    if ok;
                        args=argstr;
                        for j=1:numel(args)
                            % Substitute strings as variables, if can
                            ix=find(strcmpi(args{j},Snam),1);
                            if ~isempty(ix)
                                args{ix}=S.(args{j});
                            end
                        end
                        [ok,mess,doc]=parse_doc(args{1},doc,S,args(2:end));
                        if ~ok
                            [~,mess]=str_make_cellstr(mess,'in line:',cstr{i});
%                            mess={[mess,' in line:'],cstr{i}};
                            return
                        end
                    else
                        [~,mess]=str_make_cellstr(mess,'in line:',cstr{i});
                        return
                    end
                end
            else
                ok=false;
                mess={'Unrecognised keyword or end status in line:',cstr{i}};
                return
            end
        end
    else
        % Line needs to be a valid comment line or a substitution of a cell array of strings
        tf=(strcmpi(cstr{i},subcellnam_bra) | (cstr{i}(1)=='%' & strcmpi(strtrim(cstr{i}(2:end)),subcellnam_bra)));
        if any(tf)
            if storing
                doc=[doc,subcellval{find(tf,1)}(:)'];
            end
        elseif cstr{i}(1)=='%'
            if storing
                [line,ok,mess]=resolve(cstr{i},substrnam_bra,substrval);
                if ok
                    doc=[doc,{line}];
                else
                    mess={[mess,' in line:'],cstr{i}};
                    return
                end
            end
        else
            ok=false;
            mess={'Invalid comment line: ',cstr{i}};
            return
        end
    end
end
if ~strcmpi(main_block,blockobj(state,'current'))
    ok=false;
    mess='Block start and end(s) are inconsistent';
    return
end
