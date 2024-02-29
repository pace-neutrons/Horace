function obj = set_ba_table_from_bindata_(obj,bindata)
% restore Block Allocation Table from its binary representation

if ~isa(bindata,'uint8')
    error('HORACE:blockAllocationTable:invalid_argument', ...
        'bat_table setter accepts only uint8 array of elements, containing serialized BlockAllocationTable. The input class is: %s',...
        class(bindata));
end
obj.bat_blocks_size_ = numel(bindata); % this is block list serialization
pos = 5;                               % first 4 bytes -- number of blocks in BAT
n_bl = typecast(bindata(1:4),'uint32');
cl_table = cell(1,n_bl);
ic = 1;
while pos<numel(bindata)
    [cl_table{ic},pos]= data_block.deserialize_bat_record(bindata,pos);
    ic = ic+1;
end
obj.blocks_list = cl_table;

