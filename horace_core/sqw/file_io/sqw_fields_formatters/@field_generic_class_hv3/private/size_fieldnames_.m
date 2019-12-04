function [sz,nfields,pos]=size_fieldnames_(bytes,pos,sz)
% Restore array of field names

nfields = typecast(bytes(pos:pos+8-1),'double');
pos = pos + 8;
sz = sz + 8;
for i=1:nfields
    nf = typecast(bytes(pos:pos+8-1),'double');
    sz  = sz +  8 + nf;
    pos = pos + 8 + nf;
end

