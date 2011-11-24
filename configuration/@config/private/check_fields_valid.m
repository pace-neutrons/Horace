function [valid,mess]=check_fields_valid (structure, root_config_name)
% Check that the fields of a structure are valid as a configuration object
% - cannot contain the root config class at any depth of nesting
% - must contain a top-level field called 'sealed_fields' that is a cellstr of valid field names

if isfield(structure,'sealed_fields') && iscellstr(structure.sealed_fields) && ...
        (isempty(structure.sealed_fields) || all(ismember(structure.sealed_fields,fields(structure))))
    [valid,mess]=check_fields_valid_private (structure, root_config_name);
else
    valid=false;
    mess='missing field ''sealed_fields'' or sealed fields inconsistent with other field names';
end

%--------------------------------------------------------------------------------------------------
function [valid,mess]=check_fields_valid_private (input, root_config_name)

if iscell(input)
    for i=1:numel(input)
        [valid,mess]=check_fields_valid_private (input{i}, root_config_name);
        if ~valid, return, end
    end
elseif isstruct(input)
    names=fields(input);
    for i=1:numel(names)
        [valid,mess]=check_fields_valid_private (input.(names{i}), root_config_name);
    end
elseif isobject(input)
    if ~isa(input,root_config_name)
        for i=1:numel(input)
            [valid,mess]=check_fields_valid_private (input(i), root_config_name);
        end
    else
        valid=false;
        mess=['Configuration class cannot contain an object of class ''',root_config_name,''''];
    end
else
    valid=true;
    mess='';
end
