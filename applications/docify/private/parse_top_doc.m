function [ok, mess, source, changed] = parse_top_doc (flname, doc_filter)
% Parse meta documentation in a matlab source code file
%
%   >> [ok, mess, source, changed] = parse_top_doc (flname, doc_filter)
%
% Input:
% ------
%   flname  Name of file that contains meta-documentation if top level call
%
%   doc_filter  Determine which doc_beg...doc_end sections to parse:
%              If false: parse all sections, whether tagged with filter keyword or not
%              If true:  parse only untagged sections
%              If cell array of strings:
%                        parse only those sections tagged with one or more
%                        of the keywords in the list that is doc_filter
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
    [ok, mess, doc_new, iline_start, iline_finish, doc_found] = parse_doc ...
        (lstruct_sub, args, S, is_topfile, doc_filter);
    if ok
        if doc_found
            % Meta documentation found; discard all comments up to the start of the
            % meta documentation, replace with new documentation, insert a blank line
            % and then retain the meta documentation and the rest of the code up to
            % the next leading comment block. Repeated running of the function does
            % not change the output (the blank line that was inserted is compressed
            % away, and the resolved documentation discarded)
            ind_docstart = lstruct_sub.ind(iline_start);
            ind_docfinish = lstruct_sub.ind(iline_finish);
            
            % Get leading whitespace from first meta documentation line
            line = source_in{ind_docstart};
            pos = strfind(source_in{ind_docstart},'%');
            whitespace = line(1:pos(1)-1);
            
            % Construct demarcation line
            if ind_docfinish<numel(source_in) && is_demarcation_line (source_in{ind_docfinish+1},'-')
                % There is a demarcation line after the meta documentation lines
                demarkstr = [whitespace,strtrim(source_in{ind_docfinish+1})];
                skip_line = 1;
            else
                demarkstr = make_demarcation_line (whitespace,80,'-');
                skip_line = 0;
            end
            
            if ~isempty(doc_new)
                % Meta documentation is not empty. Indent each line in doc_new
                % by this string (recall parse_doc works with trimmed strings)
                doc_new = strcat({whitespace}, doc_new);    % {whitespace} is a trick to keep blank
            end
            source = [source, doc_new, {'',demarkstr}, source_in(ind_docstart:ind_docfinish),...
                {demarkstr},source_in(ind_docfinish+1+skip_line:ind_lo(i+1)-1)];
        else
            % No meta documentation found; leave the leading comment block unchanged
            % and collect source code up to start of next leading comment block
            source = [source, source_in(ind_lo(i):ind_lo(i+1)-1)];
        end
    else
        % Error condition; return the source unchanged
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

% --------------------------------------------------------------------------------
function str = make_demarcation_line (pre_str,len,char)
% Create a demarcation comment line
%
%   >> str = make_demarcation_line (pre_str,len,char)
%
% Input:
% ------
%   pre_str     String to precede comment symbol '%'
%               Expected to be whitespace, but can be anything in fact
%
%   len         Total length of line including whitespace
%   char        Character to be repeated e.g. '-'
%
% Output:
% -------
%   str         Character string with the requested line
%
% EXAMPLE
%   >> demarcation_line ('   ',20,'=')
%

if numel(pre_str)<len
    nchar = len - numel(pre_str) - 1;
    str = [pre_str, '%', repmat(char,1,nchar)];
else
    str = pre_str(1:len);
end

% --------------------------------------------------------------------------------
function status = is_demarcation_line (str,char)
% Determine if a string has form [whitespace]%[space]repmat(char,1,n)

strout = strtrim(str);
repchar = @(x,character) isequal(strfind(x,character),1:numel(x));
status = (numel(strout)>=2 && strcmp(strout(1),'%') && repchar(strout(2:end),char))...
    || (numel(strout)>=3 && strcmp(strout(1:2),'% ') && repchar(strout(3:end),char));

