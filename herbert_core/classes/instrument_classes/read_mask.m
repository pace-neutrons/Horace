function wout = read_mask (file)
% Read array of masked indicies from an ASCII file into a mask object
% 
%   >> w = read_mask          % prompts for file
%   >> w = read_mask (file)
%
% See <a href="matlab:help('IX_mask/read_ascii');">IX_mask/read_ascii</a> for file format details and examples


% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if nargin==0 || ~is_file(file)
    file = '*.msk';     % default for file prompt
end
[file_full, ok, mess] = getfilecheck (file);
if ~ok
    error ('HERBERT:read_mask:io_error', mess)
end

% Read data from file
% ---------------------
wout = IX_mask.read_ascii (file_full);
