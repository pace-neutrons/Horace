function [ok, mess] = check_sqw_main_header (main_header, field_names_only)
% Check that the fields in the main header are OK
%
%   >> [ok, mess] = check_sqw_main_header (main_header)
%   >> [ok, mess] = check_sqw_main_header (main_header, field_names_only)
%
% Input:
% ------
%   main_header Structure to be checked
%   fields_names_only 
%               If=true, check field names only
%                 =false or empty or absent, check all fields of permitted type(s)
%
% Output:
% -------
%   ok          OK=true if valid, OK=false if not
%   mess        Message if not a valid main_header, empty string if is valid.

% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

fields = {'filename';'filepath';'title';'nfiles'};  % column

ok=false;
mess='';

% Special case of empty structure
% ---------------------------------
if isstruct(main_header) && isempty(main_header)
    ok=true;
    return
end

% All other cases
% ----------------
% Check input options flags - these better be OK if Horace is written correctly
if ~exist('field_names_only','var')||isempty(field_names_only)
    field_names_only = false;
elseif ~(isnumeric(field_names_only)||islogical(field_names_only))
    error('Invalid argument field_names_only to check_sqw_main_header - logic problem in Horace')
end

% Check data argument
% ---------------------
% Check field names
if ~isstruct(main_header) || ~isequal(fieldnames(main_header),fields)
    mess='Main header is not a structure with required fields'; return
end


if ~field_names_only
    % Check contents of fields
    % ------------------------
    if ~is_string_or_empty_string(main_header.filename), mess='ERROR: Field ''filename'' must be a character string'; return; end
    if ~is_string_or_empty_string(main_header.filepath), mess='ERROR: Field ''filepath'' must be a character string'; return; end
    if ~is_string_or_empty_string(main_header.title), mess='ERROR: Field ''title'' must be a character string'; return; end
    if ~isa_size(main_header.nfiles,'scalar','double'), mess='ERROR: Field ''nfiles'' must be a numeric scalar'; return; end
end

% Ok if got to here
ok=true;


%==================================================================================================
function ok = is_string_or_empty_string(arg)
% Check if argument is a row character string, or an empty string
if ischar(arg) && (isempty(arg)||length(size(arg))==2 && size(arg,1)==1)
    ok=true;
else
    ok=false;
end
