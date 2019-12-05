function [ok, mess] = check_sqw_detpar (det, field_names_only)
% Check that the fields in the detector parameters are OK
%
%   >> [ok, mess] = check_sqw_detpar (det)
%   >> [ok, mess] = check_sqw_detpar (det, field_names_only)
%
% Input:
% ------
%   det     Structure to be checked
%   fields_names_only 
%           If=true, check field names only
%             =false or empty or absent, check all fields of permitted type(s)
%
% Output:
% -------
%   ok      OK=true if valid, OK=false if not
%   mess    if OK, then empty string; if ~OK contains error message

% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

fields = {'filename';'filepath';'group';'x2';'phi';'azim';'width';'height'};    % column

ok=false;
mess='';

% Special case of empty structure
% ---------------------------------
if isstruct(det) && isempty(det)
    ok=true;
    return
end

% All other cases
% ----------------
% Check input options flags - these better be OK if Horace is written correctly
if ~exist('field_names_only','var')||isempty(field_names_only)
    field_names_only = false;
elseif ~(isnumeric(field_names_only)||islogical(field_names_only))
    error('Invalid argument field_names_only to check_sqw_detpar - logic problem in Horace')
end

% Check data argument
% ---------------------
% Check field names
if ~isstruct(det) || ~all(ismember(fieldnames(det),fields))   %isequal(fieldnames(det),fields) ???
    mess='Detpar is not a structure with required fields'; return
end

if ~field_names_only
    % Check contents of fields
    % ------------------------
    % Not exhaustive, as doesn't check numerical values
    if ~is_string_or_empty_string(det.filename), mess='ERROR: Field ''filename'' must be a character string'; return; end
    if ~is_string_or_empty_string(det.filepath), mess='ERROR: Field ''filepath'' must be a character string'; return; end
    if ~isa_size(det.group,'row','double'), mess='ERROR: Field ''group'' must be a numeric row vector'; return; end
    if ~isa_size(det.x2,'row','double'), mess='ERROR: Field ''x2'' must be a numeric row vector'; return; end
    if ~isa_size(det.phi,'row','double'), mess='ERROR: Field ''phi'' must be a numeric row vector'; return; end
    if ~isa_size(det.azim,'row','double'), mess='ERROR: Field ''azim'' must be a numeric row vector'; return; end
    if ~isa_size(det.width,'row','double'), mess='ERROR: Field ''width'' must be a numeric row vector'; return; end
    if ~isa_size(det.height,'row','double'), mess='ERROR: Field ''height'' must be a numeric row vector'; return; end
    if numel(det.group)~=numel(det.x2) || numel(det.group)~=numel(det.phi) || numel(det.group)~=numel(det.azim) ||...
            numel(det.group)~=numel(det.width) || numel(det.group)~=numel(det.height)
        mess='ERROR: Check that fields group, x2, phi, azim, width and height have same size';
        return
    end
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

