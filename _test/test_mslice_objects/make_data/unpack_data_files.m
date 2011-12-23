function unpack_data_files(work_area)
% Unpack zipped spe, cut and slice files into work area
%
%   >> unpack_data_files                % unpack to c:\temp
%   >> unpack_data_files (directory)    % unpack to named absolute path

if nargin==0
    work_area='c:\temp';
end

tmp=dir('*.zip');
for i=1:numel(tmp)
    unzip(tmp(i).name,work_area);
end
