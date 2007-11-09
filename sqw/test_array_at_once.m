function a=test_array_at_once (nlen,nparts)
tic
%a=tan(rand(nlen*nparts,1).^(pi/3));
a=rand(nlen*nparts,1);
toc

