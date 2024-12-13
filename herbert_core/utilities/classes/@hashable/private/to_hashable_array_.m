function [obj,arr] = to_hashable_array_ (obj)
% Retrieve information specifying 
%
%   >> S = to_hashable_array_(obj)
%
% Input:
% ------
%   obj            Object or array of objects which are hashable
%
%
% Output:
% -------
%  arr            array of unique data -- basis for building unique object
%                 hash


% Get saveable fields
field_names = hashingFields (obj(1));

% Recursively turn serializable fields into structures
cell_dat = cell (numel(field_names), numel(obj));
for j = 1:numel(obj)
    obj_tmp = obj(j);   % get pointer to jth object to save expensive indexing
    for i = 1:numel(field_names)
        field_name = field_names{i};
        val = obj_tmp.(field_name);
        if isa(val,'hashable')
            [val,hash] = build_hash(val);
        else
        end
        cell_dat{i,j} = val;
    end
end
