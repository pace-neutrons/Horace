function a=test_array_by_parts (nlen,nparts)
tic
a=zeros(nlen*nparts,1);
toc
disp(' ')

tic
ibeg=1; iend=nlen;
for i=1:nparts
%    tic
    a(ibeg:iend)=rand(nlen,1);
%    toc;
    ibeg=ibeg+nlen; iend=iend+nlen;
end
toc
