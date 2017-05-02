function [ok, mess, doc_out, iline] = parse_doc (lstruct, is_topfile, doc_filter, args, S)
% Parse meta documentation, if any
%
%   >> [ok, mess, doc_out, iline] = parse_doc (lstruct, is_topfile, doc_filter, args, S)
%
% Input:
% ------
%   lstruct     Line structure: fields
%                   cstr        Row cellstr, trimmed both ends and blank lines removed
%                   cstr0       Row cellstr untrimmed lines but blank lines removed
%                   ind         Line numbers in original file
%                   flname      File name of original file
%                   flname_full Full file name of original file
%
%   is_topfile  True if lstruct is from the top level mfile, false otherwise
%              If true, then if there must be an explicit doc_beg line for
%              there to be meta documentation
%
%   doc_filter  Cell array (row) of strings with acceptable filter keywords
%              on the <#doc_beg:> line. If non-empty, only if one of the
%              keywords appears on the line will the documentation be
%              included. If empty, then meta-documentation will be
%              processed regardless of the value of any keywords on the
%              <#doc_beg:> line.
%
%   args        Cell array of arguments (each must be a string or cell array of
%              strings or logical scalar (or 0 or 1)
%
%   S           Structure whose fields are the names of variables and their
%              values. Fields can be:
%                   - string
%                   - cell array of strings (column vector)
%                   - logical true or false (retain value for blocks)
%
% Output:
% -------
%   ok          If all OK, then true; otherwise false
%
%   mess        Error message if not OK; empty if all OK
%
%   doc_out     Cell array of strings containing output documentation
%
%   iline       Line index in cstr of first meta documentation line; =[]
%              if no meta documentation. This line can real i.e. explicit
%              doc_def or doc_beg line, or virtual i.e. iline=0 in the
%              case of a meta documentation file (i.e. not top level mfile)
%              without explicit doc_def or doc_beg line
%
%
% Form of meta documentation file:
% --------------------------------
% Simplest form; all contents meta documentation:
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


mess = '';
doc_out = {};
iline = [];

% Find all the meta documentation blocks. Lines of texct in between will be ignored
[ok, mess_tmp, idef_arr, ibeg_arr, iend_arr] = parse_doc_blocks...
    (lstruct.cstr, is_topfile, doc_filter);
if ~ok
    mess = make_message (lstruct, 0, mess_tmp);
    return
end

% For each documentation block, parse the documentation and accumulate the
% resulting documentation from each block
if numel(ibeg_arr)>0
    iline = idef_arr(1);
    for i=1:numel(ibeg_arr)
        idef = idef_arr(i); ibeg=ibeg_arr(i); iend=iend_arr(i);
        if iend>ibeg
            % Accumulate additional definitions, if any
            if idef<ibeg
                lstruct_definitions = section_lstruct (lstruct, idef+1:ibeg-1);
                [ok, mess_tmp, Snew] = parse_doc_definitions...
                    (lstruct_definitions.cstr, args, S);
                if ~ok
                    mess_intro = 'Parsing meta documentation definitions:';
                    mess = make_message (lstruct_definitions, 0, mess_intro, mess_tmp);
                    return
                end
            else
                Snew=S;
            end
            % Get new documentation
            lstruct_docsection = section_lstruct (lstruct, ibeg+1:iend-1);
            [ok, mess_tmp, iline_err, doc_new] = parse_doc_section...
                (lstruct_docsection.cstr, Snew);
            if ~ok
                mess_intro = 'Parsing meta documentation text:';
                mess = make_message (lstruct_docsection, iline_err, mess_intro, mess_tmp);
                return
            end
            doc_out = [doc_out, doc_new];
        end
    end
end
