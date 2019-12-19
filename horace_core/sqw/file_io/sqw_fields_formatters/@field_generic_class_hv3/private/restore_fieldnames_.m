function    [names,sz,pos]=restore_fieldnames_(bytes,pos,sz)
% Restore array of field names

ntf = typecast(bytes(pos:pos+8-1),'double');
pos = pos + 8;
sz = sz + 8;
names = cell(ntf,1);
for i=1:ntf
    nf = typecast(bytes(pos:pos+8-1),'double');
    pos = pos + 8;
    names{i} = char(bytes(pos:pos+nf-1))';
    sz = sz + 8 + nf;
    pos = pos + nf;
end

