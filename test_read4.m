function data = test_read4(binfil,iax,vlo,vhi)

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

[h,mess]=get_header(fid);
if ~isempty(mess)
    fclose(fid)
    disp(mess)
    return
end

% Do some processing
nfiles = h.nfiles;

tic;
data = cell(nfiles,1);


    for i=1:4
       [dd,m]=get_sqe_datablock(fid);
       dd
    end

fclose(fid);
toc
    
    