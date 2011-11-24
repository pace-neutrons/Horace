function wout = read_cut (file)
% Read mslice/Tobyfit cut object from a file
% 
%   >> w=read_cut          % prompts for file
%   >> w=read_cut(file)

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.cut'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=cut(file_full);
