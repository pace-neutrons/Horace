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


% Get hasing fields, used for extracting values, explicitly specifying
% class state
field_names = hashableFields (obj(1));

% Recursively turn serializable fields into structures
arr = cell (1,numel(field_names)*numel(obj));
ic = 0;
for j = 1:numel(obj)
    obj_tmp = obj(j);   % get pointer to jth object to save expensive indexing
    for i = 1:numel(field_names)
        ic = ic+1;
        field_name = field_names{i};
        val = obj_tmp.(field_name);
        if isa(val,'hashable')
            [val,hash,new_hash] = build_hash(val);
            if new_hash
                obj(j).(field_name) = val;
            end
            tm = typecast(hash,'uint8');
            arr{ic} = tm(:);
        elseif isa(val,'double')
            tm = typecast(single(round(val,7)),'uint8');
            arr{ic} =tm(:);
        elseif isa(val,'single')
            tm = typecast(single(round(val,6)),'uint8');
            arr{ic} = tm(:);
        elseif isnumeric(val)
            tm = typecast(val,'uint8');
            arr{ic} = tm(:);
        elseif islogical(val)
            arr{ic} = uint8(val);
        elseif istext(val)
            arr{ic} = uint8(char(val)).';
        elseif isstruct(val)
            [val,hash] = build_hash(val);
            tm = typecast(hash,'uint8');
            arr{ic} = tm(:);
            obj(j).(field_name) = val;
        else
            arr{ic}= serialize(val);
        end
    end
end
arr = cat(1,arr{:});