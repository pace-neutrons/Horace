function [ok,mess]=put_slice_matlab(header,slice,labels,file)
% Writes ASCII .slc file
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
   
fprintf(fid,'%-8d %-8d %-17.5g %-17.5g %-17.5g %-17.5g \n',header);
index=[0 cumsum(slice.npixels(:))'];
for i=1:numel(slice.npixels),
    fprintf(fid,'%-17.5g%-17.5g%-17.5g%-17.5g%-12d\n',slice.x(i),slice.y(i),slice.c(i),slice.e(i),slice.npixels(i));
    fprintf(fid,'%-9d%-17.5g%-17.5g%-17.5g%-17.5g%-17.5g%-17.5g\n',slice.pixels((1+index(i)):index(i+1),:)');
end

for i=1:numel(labels)
    fprintf(fid,'%-s\n',labels{i});
end

fclose(fid);
