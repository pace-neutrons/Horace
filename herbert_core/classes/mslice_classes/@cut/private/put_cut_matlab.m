function [ok,mess]=put_cut_matlab(cut,labels,file)
% Writes ASCII .cut file
%   >> [ok,mess]=put_cut_matlab(cut,labels,file)
%
% The format of the file is described in get_cut. Must make sure get_cut and put_cut are consistent.
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true

% T.G.Perring   15 August 2009

ok=true;
mess='';

fid = fopen (file, 'wt');
if (fid < 0)
    ok=false;
    mess=['ERROR: cannot open file ' file];
    return
end
   
n=length(cut.x);
fprintf(fid,'%-8d\n',n);
index=[0 cumsum(cut.npixels(:))'];
for i=1:n,
    fprintf(fid,'%17.5g%17.5g%17.5g%12d\n',cut.x(i),cut.y(i),cut.e(i),cut.npixels(i));
    fprintf(fid,'%9d%17.5g%17.5g%17.5g%17.5g%17.5g\n',cut.pixels((1+index(i)):index(i+1),:)');
end

for i=1:numel(labels)
    fprintf(fid,'%-s\n',labels{i});
end

fclose(fid);
