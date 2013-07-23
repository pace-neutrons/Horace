function unpack_data_files(work_area)
% Unpack saved zipped spe, cut and slice files into work area
%
%   >> unpack_data_files                % Matlab tempdir (type >> help tempdir for more information)
%   >> unpack_data_files (directory)    % unpack to named absolute path

if nargin==0
    work_area=tempdir;
end

rootpath=fileparts(mfilename('fullpath'));

tmp=dir(fullfile(rootpath,'make_data','test*.zip'));
for i=1:numel(tmp)
    unzip(fullfile(rootpath,'make_data',tmp(i).name),work_area);
end
