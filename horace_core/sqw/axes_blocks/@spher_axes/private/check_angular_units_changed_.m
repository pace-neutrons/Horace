function  [is_present,new_value] = check_angular_units_changed_(obj,varargin)
%CHECK_ANGULAR_UNITS_CHANGED verifies if property 'angles_in_rad' is
%present within input arguments and extracts its value.
%
% This property, if present, have to be set first to be able to treat
% other posible angular parameters properly.

new_value = [];
is_possible_key = cellfun(@istext,varargin);

possible_key = varargin(is_possible_key);

is_present = ismember('angles_in_rad',possible_key);
if is_present
    key_pos = find(ismember(possible_key,'angles_in_rad'));
    new_value= possible_key(key_pos+1);
    return;
end
% whatever unlikely, 'angles_in_rad' may be provided as positional
% parameter. We still need to check this

keys = obj.saveableFields(); %angles_in_rad is the last positional parameter
if numel(varargin)< numel(keys)
    return;
end
nkeys = numel(keys);
is_possible_key = cellfun(@istext,varargin(1:nkeys));
possible_key = varargin(is_possible_key);
if any(ismember(keys,possible_key)) % key parameters have been found
    % in the constructor before necessary value parameter is found
    return;
end
% there are nkeys positional parameters and last must be 'angles_in_rad'
% value
is_present = true;
new_value = varargin{nkeys};