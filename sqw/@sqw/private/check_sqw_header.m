function [ok, mess,header] = check_sqw_header (header,field_names_only)
% Check that the fields in the header are OK
%
%   >> [ok, mess] = check_sqw_header (header)
%   >> [ok, mess] = check_sqw_header (header, field_names_only)
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
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

fields = {'filename';'filepath';'efix';'emode';'alatt';'angdeg';'cu';'cv';'psi';...
    'omega';'dpsi';'gl';'gs';'en';'uoffset';'u_to_rlu';'ulen';'ulabel';'instrument';'sample'};    % column

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
    error('Invalid argument field_names_only to check_sqw_header - logic problem in Horace')
end


% Check fields and, if requested, their contents
% ----------------------------------------------
if isstruct(header)
    if ~isequal(fieldnames(header),fields)
        mess='Header is not a structure with required fields'; return
    elseif ~field_names_only
        for i=1:numel(header)
            [ok,mess,header(i)]=check_sqw_header_fields(header(i));
            if ~ok, return, end
        end
    end
    
elseif iscell(header) && numel(header)>1    % must have more than one entry
    for i=1:numel(header)
        if ~isequal(fieldnames(header{i}),fields)
            mess='Header is not a structure with required fields'; return
        elseif ~field_names_only
            [ok,mess]=check_sqw_header_fields(header{i});
            if ~ok, return, end
        end
    end
    
else
    mess='Header must be a structure or cell array length>2 of structures with correct fields';
    return
end

% Ok if got to here
ok=true;


%==================================================================================================
function [ok,mess,header]=check_sqw_header_fields(header)
%   >> [ok, mess] = check_sqw_header_fields (header)
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

if ~isa_size(header.emode,'scalar','double') || ~(header.emode==1 || header.emode==2 || header.emode==0)
    mess='ERROR: Field ''emode'' must be a number equal to either 1 or 2'; return; end

if header.emode == 1
    if ~isa_size(header.efix,'scalar','double')
        mess='ERROR: Field ''efix'' must be a numeric scalar';
        return;
    end
elseif header.emode == 2
    if ~isa_size(header.efix,'scalar','double')
        ndet = size(header.efix);
        if ~isa_size(header.efix,ndet,'double')
            mess='ERROR: Field ''efix'' in Indirect mode must be a numeric scalar or array of size equal to number of detectors';
            return;
        end
    end
    
else
    if (isnumeric(header.efix) && header.efix==0) ||...
            (ischar(header.efix) && strncmpi(header.efix,'no efix for elastic',19)) % elastic mode
        header.efix = 0;
    else
        mess='ERROR: Field ''efix'' must be a numeric scalar';
        return;
        
    end
end

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
if header.uoffset(4)~=0; mess='ERROR: Energy offset ''uoffset(4)'' must be zero'; return; end
if ~isa_size(header.u_to_rlu,[4,4],'double'); mess='ERROR: field ''u_to_rlu'' must be a 4x4 matrix of numbers'; return; end
if ~isa_size(header.ulen,[1,4],'double'); mess='ERROR: field ''ulen'' must be a row vector of 4 numbers'; return; end
if ~isa_size(header.ulabel,[1,4],'cellstr'); mess='ERROR: field ''ulabel'' must be a (row) cell array of 4 strings'; return; end
% Contents of instrument or sample fields must be a scalar structure or object, but otherwise can be anything.
if numel(header.instrument)~=1 || ~(isobject(header.instrument)||isstruct(header.instrument))
    mess='ERROR: instrument descriptor must be a scalar structure or object';
    return
end
if numel(header.sample)~=1 || ~(isobject(header.sample)||isstruct(header.sample))
    mess='ERROR: sample descriptor must be a scalar structure or object';
    return
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
