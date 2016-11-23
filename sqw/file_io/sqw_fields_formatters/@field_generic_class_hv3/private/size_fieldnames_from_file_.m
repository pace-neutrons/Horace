function [sz,nfields,pos,err]=size_fieldnames_from_file_(fid,pos,sz)
% Restore array of field names
err = false;
nfields  = fread(fid,1,'float64');
[~,res] = ferror(fid);
if res ~=0; err = true; return; end

pos = pos + 8;
sz = sz + 8;
for i=1:nfields
    nf = fread(fid,1,'float64');
    [~,res] = ferror(fid);
    if res ~=0; err = true; return; end
    
    sz  = sz +  8 + nf;
    pos = pos + 8 + nf;
    fseek(fid,pos,'bof');
    [~,res] = ferror(fid);
    if res ~=0; err = true; return; end
    
end

