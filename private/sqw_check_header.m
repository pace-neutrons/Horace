function [ok, mess] = sqw_check_header (header,field_names_only)
% Check that the fields in the header are OK
%
%   >> [ok, mess] = sqw_check_header (header)
%   >> [ok, mess] = sqw_check_header (header, field_names_only)
%
% Input:
% ------
%   header  Structure to be checked
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
% $Revision: 101 $ ($Date: 2007-01-25 09:10:34 +0000 (Thu, 25 Jan 2007) $)

fields = {'filename';'filepath';'efix';'emode';'alatt';'angdeg';'cu';'cv';'psi';...
    'omega';'dpsi';'gl';'gs';'en';'uoffset';'u_to_rlu';'ulen';'ulabel'};    % column

ok=false;
mess='';

% Special case of empty structure
% ----------------------------------
if isstruct(header) && isempty(header)
    ok=true;
    return
end

% All other cases
% ----------------
% Check input options flags - these better be OK if Horace is written correctly
if ~exist('field_names_only','var')||isempty(field_names_only)
    field_names_only = false;
elseif ~(isnumeric(field_names_only)||islogical(field_names_only))
    error('Invalid argument field_names_only to sqw_check_header - logic problem in Horace')
end


% Check fields and, if rewuested, their contents
% ----------------------------------------------
if isstruct(header)
    if ~isequal(fieldnames(header),fields)
        mess='Header is not a structure with required fields'; return
    elseif ~field_names_only
        [ok,mess]=sqw_check_header_fields(header);
        if ~ok, return, end
    end
    
elseif iscell(header) && numel(header)>1    % must have more than one entry
    for i=1:numel(header)
        if ~isequal(fieldnames(header{i}),fields)
            mess='Header is not a structure with required fields'; return
        elseif ~field_names_only
            [ok,mess]=sqw_check_header_fields(header{i});
            if ~ok, return, end
        end
    end
    
else
    mess='Header must be a structure of cell array length>2 of structures with correct fields';
    return
end

% Ok if got to here
ok=true;


%==================================================================================================
function [ok,mess]=sqw_check_header_fields(header)
%   >> [ok, mess] = sqw_check_header_fields (header)
%
%   ok      OK=true if valid, OK=false if not
%   mess    if OK, then empty string; if ~OK contains error message

% Check fields. Not exhaustive, as doesn't check numerical values in the main, or consistency between fields
% (e.g. should check consistency of the lattice parameters, u_to_rlu etc.)

ok=false;
mess='';

% Not exhaustive, as doesn't check numerical values
if ~is_string_or_empty_string(header.filename), mess='ERROR: Field ''filename'' must be a character string'; return; end
if ~is_string_or_empty_string(header.filepath), mess='ERROR: Field ''filepath'' must be a character string'; return; end
if ~isa_size(header.efix,'scalar','double'), mess='ERROR: Field ''efix'' must be a numeric scalar'; return; end
if ~isa_size(header.emode,'scalar','double') || ~(header.emode==1 || header.emode==2)
    mess='ERROR: Field ''emode'' must be a number equal to either 1 or 2'; return; end
if ~isa_size(header.alatt,'vector','double'), mess='ERROR: Field ''alatt'' must be a numeric vector length 3'; return; end
if ~isa_size(header.angdeg,'vector','double'), mess='ERROR: Field ''andeg'' must be a numeric vector length 3'; return; end
if ~isa_size(header.cu,'vector','double'), mess='ERROR: Field ''cu'' must be a numeric vector length 3'; return; end
if ~isa_size(header.cv,'vector','double'), mess='ERROR: Field ''cv'' must be a numeric vector length 3'; return; end
if ~isa_size(header.psi,'scalar','double'), mess='ERROR: Field ''psi'' must be a numeric scalar'; return; end
if ~isa_size(header.omega,'scalar','double'), mess='ERROR: Field ''omega'' must be a numeric scalar'; return; end
if ~isa_size(header.dpsi,'scalar','double'), mess='ERROR: Field ''dpsi'' must be a numeric scalar'; return; end
if ~isa_size(header.gl,'scalar','double'), mess='ERROR: Field ''gl'' must be a numeric scalar'; return; end
if ~isa_size(header.gs,'scalar','double'), mess='ERROR: Field ''gs'' must be a numeric scalar'; return; end
if ~isa_size(header.uoffset,[4,1],'double'); mess='ERROR: field ''uoffset'' must be a column vector of 4 numbers'; return; end
if ~isa_size(header.u_to_rlu,[4,4],'double'); mess='ERROR: field ''u_to_rlu'' must be a 4x4 matrix of numbers'; return; end
if ~isa_size(header.ulen,[1,4],'double'); mess='ERROR: field ''ulen'' must be a row vector of 4 numbers'; return; end
if ~isa_size(header.ulabel,[1,4],'cellstr'); mess='ERROR: field ''ulabel'' must be a (row) cell array of 4 strings'; return; end

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
