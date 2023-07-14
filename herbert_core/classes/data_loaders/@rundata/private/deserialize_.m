function [rd,size] = deserialize_(iarr)
% Deserialize rundata object serialized earlier into series of bytes
size = typecast(iarr(1:8),'uint64');
if size>numel(iarr)-8
    error('RUNDATA:deserialize',' The stored rundata object size is larger then byte array size provided');
end

if verLessThan('matlab','7.12')
    str = deserialize(iarr(9:double(size+8)));    
else
    str = deserialize(iarr(9:size+8));
end

rd= set_up_from_struct_(str);