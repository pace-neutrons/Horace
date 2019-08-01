function wout = read_map (file)
% Read .map object from a file
% 
%   >> w=read_map          % prompts for file
%   >> w=read_map(file)

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.map'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=IX_map(file_full);
