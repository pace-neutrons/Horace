function [ok,mess]=test_sparse
% Test Horace sparse array routines write_sparse, write_sparse2, read_sparse, read_sparse2

% Create column vector with length 20:
ind=[2,9,12,16,18,19];
val=[0.197854175289323,0.247930843506804,0.219225577799816,...
    0.476263605659404,0.864315906262281,0.039050161731324];
a8=sparse(ind,1,val,20,1);
ia=round(20*a8);         % array with purely integer values
a4=sparse(double(single(full(a8))));   % array with single precision accuracy only

% Perform write/read tests
file='c:\temp\crap.dat';
ok=true;

% Test of write_sparse, read_sparse
mess=test(a8,'float64',file); if ~isempty(mess), ok=false; mess=[mess,': float64']; return ,end
mess=test(ia,'int32',file);   if ~isempty(mess), ok=false; mess=[mess,': int32']; return ,end
mess=test(a4,'float32',file); if ~isempty(mess), ok=false; mess=[mess,': float32']; return, end

% Test of write_sparse2, read_sparse2
nrange=[11,17];
irange=[3,4];
mess=test2(a8,'float64',file,nrange,irange); if ~isempty(mess), ok=false; mess=[mess,': float64']; return ,end
mess=test2(ia,'int32',file,nrange,irange);   if ~isempty(mess), ok=false; mess=[mess,': int32']; return ,end
mess=test2(a4,'float32',file,nrange,irange); if ~isempty(mess), ok=false; mess=[mess,': float32']; return, end

%--------------------------------------------------------------------------------------
function mess=test(a,type,file)
% Test write-read preserves the array

fid=fopen(file,'wb');
write_sparse(fid,a,type);
pos_ref=ftell(fid);
fwrite(fid,-99*ones(317,1));    % add some stuff at the end
fclose(fid);

% Read and test output is same as input, with position in correct place
fid=fopen(file,'rb');
aread=read_sparse(fid);
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse: position error';
    return
elseif ~isequal(a,aread)
    mess='sparse: write-read does not preserve array values';
    return
end

% Check full option works
fid=fopen(file,'rb');
aread=read_sparse(fid,true);
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse: position error';
    return
elseif ~isequal(full(a),aread)
    mess='sparse: write-read does not preserve array values with full==true';
    return
end

% Check negation of full option works
fid=fopen(file,'rb');
aread=read_sparse(fid,false);
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse: position error';
    return
elseif ~isequal(a,aread)
    mess='sparse: write-read does not preserve array values with full==false';
    return
end

% Skip data
fid=fopen(file,'rb');
aread=read_sparse(fid,'skip');
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse: position error with skip';
    return
elseif ~isempty(aread)
    mess='sparse: read somethng into the array with skip';
    return
end

mess='';

%--------------------------------------------------------------------------------------
function mess=test2(a,type,file,nrange,irange)
% Test write-read preserves the array

fid=fopen(file,'wb');
write_sparse2(fid,a,type);
pos_ref=ftell(fid);
fwrite(fid,-99*ones(317,1));    % add some stuff at the end
fclose(fid);

% Read and test output is same as input, with position in correct place
fid=fopen(file,'rb');
aread=read_sparse2(fid);
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse2: position error';
    return
elseif ~isequal(a,aread)
    mess='sparse2: write-read does not preserve array values';
    return
end

% Test full option works
fid=fopen(file,'rb');
aread=read_sparse2(fid,true);
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse2: position error';
    return
elseif ~isequal(full(a),aread)
    mess='sparse2: write-read does not preserve array values with full==true';
    return
end

% Test negation of full option works
fid=fopen(file,'rb');
aread=read_sparse2(fid,false);
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse2: position error';
    return
elseif ~isequal(a,aread)
    mess='sparse2: write-read does not preserve array values with full==false';
    return
end

% Skip data
fid=fopen(file,'rb');
aread=read_sparse2(fid,'skip');
pos=ftell(fid);
fclose(fid);
if pos~=pos_ref;
    mess='sparse2: position error with skip';
    return
elseif ~isempty(aread)
    mess='sparse2: read somethng into the array with skip';
    return
end

% Read a bit of data, and test output is same as input
asub=a(nrange(1):nrange(2));
fid=fopen(file,'rb');
aread=read_sparse2(fid,type,nrange,irange);
fclose(fid);
if ~isequal(asub,aread)
    mess='sparse2: write-read does not preserve sub-section values';
    return
end

% Read a bit of data, and test output is same as input, with full==true
asub=a(nrange(1):nrange(2));
fid=fopen(file,'rb');
aread=read_sparse2(fid,type,nrange,irange,true);
fclose(fid);
if ~isequal(full(asub),aread)
    mess='sparse2: write-read does not preserve sub-section values';
    return
end


mess='';
