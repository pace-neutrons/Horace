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

y = 0;
nread = 120000;
tic;
for i=1:h.nfiles
%    disp('-----------------------')
    [data.ei,count,ok,mess] = fread_catch(fid, 1, 'float32'); if ~all(ok); return; end;
    data.ei;
    [data.psi,count,ok,mess] = fread_catch(fid, 1, 'float32'); if ~all(ok); return; end;
    [data.cu,count,ok,mess] = fread_catch(fid, [1,3], 'float32'); if ~all(ok); return; end;
    [data.cv,count,ok,mess] = fread_catch(fid, [1,3], 'float32'); if ~all(ok); return; end;
    [n,count,ok,mess] = fread_catch(fid, 1, 'int32'); if ~all(ok); return; end;
    [data.file,count,ok,mess] = fread_catch(fid, [1,n], '*char'); if ~all(ok); return; end;
    [data.size,count,ok,mess] = fread_catch(fid, [1,2], 'int32'); if ~all(ok); return; end;
    nt= data.size(1)*data.size(2);
%    disp(num2str(nt));
    % read only the first nread elements of v array:
    [data.v,count,ok,mess] = fread_catch(fid, [3,nread], 'float32'); if ~all(ok); return; end;
%    disp(num2str(data.v(1,1)+data.v(3,nread)));
    y = y + data.v(1,1)+data.v(3,nread);
    noffset = 4*(3*nt - 3*nread);
    fseek(fid,noffset,'cof');
    [data.en,count,ok,mess] = fread_catch(fid, [1,data.size(2)], 'float32'); if ~all(ok); return; end;
    % skip S and ERR:
    noffset = 4*(2*nt);
    fseek(fid,noffset,'cof');
%     [data.S,count,ok,mess] = fread_catch(fid, [1,nt], 'float32'); if ~all(ok); return; end;
%     [data.ERR,count,ok,mess] = fread_catch(fid, [1,nt], 'float32'); if ~all(ok); return; end;
end
disp('-----------------------');
fclose(fid);
toc
y = nt;
    