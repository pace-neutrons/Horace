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

% format is (binfil)
if nargin<=1
    fclose(fid);
    data = h;
    return
end

% Do some processing
nfiles = h.nfiles;

tic;
data = cell(nfiles,1);

if nargin==4
    % format is (binfil,iax,vlo,vhi):
    for i=1:nfiles
        [data{i},mess,lis]=get_sqe_datablock(fid,[iax,vlo,vhi]);
        data{i}.lis = lis;
    end
elseif nargin==2
    % format is (binfil,axis):
    for i=1:nfiles
        [data{i},mess,lis]=get_sqe_datablock(fid,iax);
        data{i}.lis = lis;
    end
else
    disp('problem')
end

fclose(fid);
toc
    
    