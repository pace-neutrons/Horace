function flnames=unpack_data_files
% Unpack saved zipped spe, cut and slice files into work area
%
%   >> flnames=unpack_data_files 
%
% Author: T.G.Perring

rootpath=fileparts(mfilename('fullpath'));
tmp=dir(fullfile(rootpath,'testdata*.zip'));
flnames={};
for i=1:numel(tmp)
    flnames=[flnames,unzip(fullfile(rootpath,tmp(i).name),tempdir)];
end
