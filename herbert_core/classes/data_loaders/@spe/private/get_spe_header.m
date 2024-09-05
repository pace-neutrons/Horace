function data=get_spe_header(filename)
% Load header information of ASCII .spe file
%   >> [data,ok,mess] = get_spe_header(filename)
%
% data has following fields:
%   data.filename   Name of file excluding path
%   data.filepath   Path to file including terminating file separator
%   data.ndet       Number of detector groups
%   data.en         Column vector of energy bin boundaries

% Original author: T.G.Perring


filename=strtrim(filename);

    % Get file name and path (incl. final separator)
[path,name,ext]=fileparts(filename);
data.filename=[name,ext];
data.filepath=[path,filesep];

[data.ne,data.ndet,data.en] = read_spe(filename,'-info');
