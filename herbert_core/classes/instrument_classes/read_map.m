function wout = read_map (file)
% Read map data from an ASCII file (conventional extension: .map)
% 
%   >> w = read_map          % prompts for file
%   >> w = read_map (file)
%
% See <a href="matlab:help('IX_map/read_ascii');">IX_map/read_ascii</a> for file format details and examples


% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if nargin==0 || ~is_file(file)
    file = '*.map';     % default for file prompt
end
[file_full, ok, mess] = getfilecheck (file);
if ~ok
    error ('HERBERT:read_map:io_error', mess)
end

% Read data from file
% ---------------------
wout = IX_map.read_ascii (file_full);
