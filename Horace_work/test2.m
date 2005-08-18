function y = test_read(binfil)

if nargin>0
    if isa_size(binfil,'row','char')
        if (exist(binfil,'file')==2)
            file_internal = binfil;
        else
            file_internal = genie_getfile(binfil);
        end
    else
        file_internal = genie_getfile;
    end
else
    file_internal = genie_getfile;
end
if (isempty(file_internal))
    error ('No file given')
end

% Open binary file:
fid = fopen(file_internal,'r');
if fid<0
    error (['ERROR: Unable to open file ',file_internal])
end
disp('Reading binary file ...');

h=get_header(fid);

nread = 60000;
tic;
%for i=1:h.nfiles
for i=1:3
    hblock = get_spe_datablock(fid);
    hblock.ei
end
fclose(fid);
toc
y = nt;
    