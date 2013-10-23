function unpack_data_files
% Unpack saved zipped spe, cut and slice files into work area
%
%   >> unpack_data_files 
%
% Author: T.G.Perring

rootpath=fileparts(mfilename('fullpath'));
tmp=dir(fullfile(rootpath,'test*.zip'));
for i=1:numel(tmp)
    unzip(fullfile(rootpath,tmp(i).name),tempdir);
end
