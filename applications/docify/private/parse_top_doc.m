function [ok, mess, source, changed] = parse_top_doc (flname, doc_filter)
% Parse meta documentation source (file or cell array of strings)
%
%   >> [ok, mess, source, changed] = parse_top_doc (flname, doc_filter)
%
% Input:
% ------
%   flname  Name of file that contains meta-documentation if top level call
%
%   doc_filter  Cell array of strings with acceptable filter keywords
%          on the <#doc_beg:> line. If non-empty, only if one of the
%          keywords appears on the line will the documentation be
%          included
%
% Output:
% -------
%   ok      =true if all OK, =false if not
%
%   mess    Message. It may have contents even if OK==true, in which case
%          it is purely informational or warning.
%
%   source  Source code with meta-documentation replacing that in the
%          original file.
%
%   changed True if meta-documentation parsing changes the source; false
%           otherwise
%
%
% Meta documentation format:
% --------------------------
% Each function or classdef, properties or methods section can contain
% one or more meta documentation blocks before the first executable line:
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


% Get data from source
[ok, mess, lstruct, source_in] = read_file (flname);
if ~ok
    source = source_in; changed = false;
    return
end

% Find leading comment blocks after classdef, function, properties, methods statements
[ilo,ihi] = parse_top_doc_comment_blocks (lstruct.cstr);
if isempty(ilo)
    source = source_in; changed = false;
    return
end

% Parse the documentation in each comment block, if any
ind_lo = [lstruct.ind(ilo),numel(source_in)+1]; % actual line number in original source code
source = source_in(1:ind_lo(1)-1);      % source code up to the first leading comment block

is_topfile = true;  % top level file to be parsed
args = {};          % no arguments to be passed to meta documentation
S = struct();       % structure with no fields - no accumulated variables
for i=1:numel(ilo)
    lstruct_sub = section_lstruct (lstruct, ilo(i):ihi(i));
    [ok, mess, doc_new, iline] = parse_doc (lstruct_sub, is_topfile, doc_filter, args, S);
    if ok
        if ~isempty(doc_new)
            % Meta documentation found; discard all comments up to the start of the
            % meta documentation, replace with new documentation, insert a blank line
            % and then retain the meta documentation and the rest of the code up to
            % the next leading comment block. Repeated running of the function does
            % not change the output (the blank line that was inserted is compressed
            % away, and the resolved documentation discarded)
            ind_docstart = lstruct_sub.ind(iline);
            
            % Get leading whitespace from first meta documentation line
            line = source_in{ind_docstart};
            pos = strfind(source_in{ind_docstart},'%');
            whitespace = line(1:pos(1)-1);
            
            % Indent each line in doc_new by this string (recall parse_doc works
            % with trimmed strings)
            doc_new = strcat({whitespace}, doc_new);    % {whitespace} is a trick to keep blank
            
            source = [source, doc_new, {''}, source_in(ind_docstart:ind_lo(i+1)-1)];
        else
            % No meta documentation found; leave the leading comment block unchanged
            % and collect source code up to start of next leading comment block
            source = [source, source_in(ind_lo(i):ind_lo(i+1)-1)];
        end
    else
        source = source_in; changed = false;
        return
    end
end

% Check if the source changed
if numel(source)==numel(source_in) && all(strcmp(source,source_in))
    changed = false;
else
    changed = true;
end
