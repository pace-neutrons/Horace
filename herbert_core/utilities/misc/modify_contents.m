function cont = modify_contents(cont,var_pos,var_map)
% function change cellarray of contenst using var_map, for further export
% of the modified data in bash file
%
% Inputs:
% cont    -- cellarray of strings
% var_pos -- map, containing pairs of Key -> position,
%            where keys are the names of the variables to replays and the
%            values define the rows numbers in cont cellarry where the
%            definition for these variables should be placed
% var_map -- the map containing key->values to define the contents of the
%            new bash file variables.
%

if isempty(var_pos)
    var_pos = containers.Map();
end

keys_to_add = var_map.keys;
for i=1:numel(keys_to_add)
    theKey = keys_to_add{i};
    contents = sprintf('export %s=''%s''',theKey,var_map(theKey));
    if var_pos.isKey(theKey)
        pos = var_pos(theKey);
        cont{pos} = contents;
    else
        if isempty(cont{end})
            cont{end} = contents;            
        else
            cont{end+1} = contents;
        end
    end
end
%
if ~isempty(cont{end})
    cont{end+1} = '';    
end
