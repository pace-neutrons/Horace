function [valid,mess,structure_out]=check_fields_valid (structure, root_config_name)
% Check that the fields of a structure are valid as a configuration object
%
%   >> [valid,mess,structure_out]=check_fields_valid (structure, root_config_name)
%
% Input:
% ------
%   structure           Structure of configuration object. It is valid so long
%                      as it does not contain the root configuration class at
%                      any depth of nesting
%   root_config_name    Name of root configuration object
%
% Output:
% -------
%   valid               true or false
%   mess                Empty if valid; error message if not valid
%   structure_out       Structure with correct format
%                       - If 'sealed_fields' was not a field, then it is added
%                        with the value {'sealed_fields'}
%                       - Ensures that 'sealed_fields' is the last field
%                        in the structure (this is the standard format)

% $Revision$ ($Date$)

structure_out=structure;
if isfield(structure_out,'sealed_fields')
    [valid,mess,sealed_fields]=valid_sealed_fields(structure_out.sealed_fields,fieldnames(structure_out));
    if ~valid, return, end
    % Put sealed fields at the end of the structure
    structure_out=rmfield(structure_out,'sealed_fields');
    structure_out.sealed_fields=sealed_fields;
else
    [valid,mess,sealed_fields]=valid_sealed_fields({},{});  % ensures full consistency
    structure_out.sealed_fields=sealed_fields;
end

[valid,mess]=check_fields_valid_private (structure_out, root_config_name);

%--------------------------------------------------------------------------------------------------
function [valid,mess]=check_fields_valid_private (input, root_config_name)
% Find out if there is a root config object hidden somewhere in the structure: check
% fields that are cell arrays or structures as well as straightforward determination 
% if a field that is an object (or array of objects) is a root config object or a child
% of a root config object.
%
% *** Not bullet-proof: an object could contain a field that is a root config object
%     but which was not declared as inherited i.e. could be an aggregation. Could add
%     an extra bit of code check.

if iscell(input)
    for i=1:numel(input)
        [valid,mess]=check_fields_valid_private (input{i}, root_config_name);
        if ~valid, return, end
    end
elseif isstruct(input)
    names=fieldnames(input);
    for i=1:numel(names)
        [valid,mess]=check_fields_valid_private (input.(names{i}), root_config_name);
        if ~valid, return, end
    end
elseif isobject(input)
    if ~isa(input,root_config_name)
        for i=1:numel(input)
            [valid,mess]=check_fields_valid_private (input(i), root_config_name);
            if ~valid, return, end
        end
    else
        valid=false;
        mess=['Configuration class cannot contain an object of class ''',root_config_name,''''];
        return
    end
end
valid=true;
mess='';
