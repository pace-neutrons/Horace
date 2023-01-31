function bindata = get_ba_table_bindata(obj)
% generate BAT binary representation to store Block
% Allocation Table in file

n_obj = obj.n_blocks;
bindata = cell(1,n_obj+1);
bindata{1} = typecast(uint32(n_obj),'uint8');
for i=1:n_obj
    bindata{i+1} = (obj.blocks_list_{i}.bat_record)';
end
bindata = [bindata{:}];
