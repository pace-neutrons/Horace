function [valid,mess]=check_fields_valid (structure, root_config_name)
% Check that the fields of a structure are valid as a configuration object
%
% $Revision$ ($Date$)
%
%
%   >> [valid,mess]=check_fields_valid (structure, root_config_name)
%
%   structure           Structure
%   root_config_name    Name of root configuration object
%
%   valid               true or false
%   mess                empty if valid; error message if not valid
%
% A structure is valid so long as it satisfies teh following:
%   - Cannot contain the root config class at any depth of nesting
%   - Must contain a top-level field called 'sealed_fields' that is a cellstr of valid field names

if isfield(structure,'sealed_fields')
    [valid,mess]=valid_sealed_fields(structure.sealed_fields,fieldnames(structure));
    if ~valid, return, end
    [valid,mess]=check_fields_valid_private (structure, root_config_name);
else
    valid=false;
    mess='missing field ''sealed_fields''';
end

%--------------------------------------------------------------------------------------------------
function [valid,mess]=check_fields_valid_private (input, root_config_name)
% Find out if thereis a root config object hidden somewhere in the structure: check
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
    names=fields(input);
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
