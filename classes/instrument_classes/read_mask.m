function wout = read_mask (file)
% Read array of masked indicies from a file into a mask object
% 
%   >> w=read_mask          % prompts for file
%   >> w=read_mask(file)

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.msk'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=IX_mask(file_full);
