function sqw_dnd = check_and_get_data_(val)
% Verify and build if necessary sqw_dnd_data field

if isa(val,'data_sqw_dnd')
    sqw_dnd = val;
else
    sqw_dnd = data_sqw_dnd(val);
end

