

mex -setup C++

copyfile(fullfile(matlabroot,"extern","examples","mex","arrayProduct.c"))

mex arrayProduct.c

s = 5; 
A = [1.5, 2, 9];
B = arrayProduct(s,A);

ext = mexext;
extlist = mexext('all');
for k=1:length(extlist)
   if strcmp(extlist(k).arch, 'maci64')
   disp(sprintf('Arch: %s  File Extension: %s', extlist(k).arch, extlist(k).ext))
   end
end
