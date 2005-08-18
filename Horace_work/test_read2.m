function y = test_read2(binfil)

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

tic;
for i=1:h.nfiles
    disp('-----------------------');
    [data,mess]=get_spe_datablock(fid,[4,7,7.5]);
    data.size
end
disp('-----------------------');
fclose(fid);
toc
y = data;
    