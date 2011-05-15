function write_ascii_fid(this,fid,name)
% G|eneric method for writing an object to an ascii file
fnames=fieldnames(this(1));
for i=1:numel(this)
    fprintf (fid, '%s\n', [name,' = $',class(this)]);
    for j=1:numel(fnames)
        write_ascii_fid(this.(fnames{i}),fid,fnames{i});
    end
end
