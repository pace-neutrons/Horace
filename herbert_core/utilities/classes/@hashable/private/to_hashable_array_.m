function [obj,arr] = to_hashable_array_ (obj)
% Retrieve information specifying
%
%   >>[obj,S] = to_hashable_array_(obj)
%
% Input:
% ------
%   obj -- Object or array of objects which are hashable, possibly
%          containing subobjects which are hashable with calculated
%          or not calculated hashes.
%
% Output:
% -------
%  obj  --  input object, containing possible children hashable objects
%           wich calculated hashes.
%  arr  --  uint8 array of unique data -- basis for building unique object
%           hash.


% Get hasing fields, used for extracting values, explicitly specifying
% class state
field_names = hashableFields (obj(1));

% Recursively turn hashable fields values into array which defines
% object's hash
arr = cell (1,numel(field_names)*numel(obj)+1);
arr{1} = uint8(class(obj))'; % ensure hashable array never empty and two
% different empty objects of different classes do not have the same hashes.
ic = 1;
for j = 1:numel(obj)
    obj_tmp = obj(j);   % get cow pointer to j-th object to save expensive indexing
    for i = 1:numel(field_names)
        ic = ic+1;
        field_name = field_names{i};
        val = obj_tmp.(field_name);
        if isa(val,'hashable')
            [val,hash,new_hash] = build_hash(val);
            if new_hash
                obj(j).do_check_combo_arg = false; % if this operation is
                % part of constructor we do not need to check combo_values.
                % It may fail.
                obj(j).(field_name) = val;
                obj(j).do_check_combo_arg = true;
            end
            %-----> hash class dependent block
            % the operation below work only for MD5 hash in string form
            % if we ever decided to switch to uint64-bit hash, operations
            % with container modification become an order of magnitude
            % faster. This block must change is such case.
            if iscell(hash) % use array of hashes as source for final hash
                hash = strjoin(hash ,'');
            end
            tm = uint8(hash); % use uint8 for char hash.
            %                   Use typecast for numeric hash.
            %<----- end of hash-class dependent block
            arr{ic} = tm(:);
        elseif isa(val,'double')
            tm = typecast(single(round(val(:),7)),'uint8');
            arr{ic} =tm(:);
        elseif isa(val,'single')
            tm = typecast(single(round(val(:),6)),'uint8');
            arr{ic} = tm(:);
        elseif isnumeric(val)
            tm = typecast(val(:),'uint8');
            arr{ic} = tm(:);
        elseif islogical(val)
            arr{ic} = uint8(val(:));
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
