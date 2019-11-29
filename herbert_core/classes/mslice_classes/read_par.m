function wout = read_par (file)
% Read mslice/Tobyfit .par object from a file
% 
%   >> w=read_par          % prompts for file
%   >> w=read_par(file)

% Original author: T.G.Perring

% Get file name - prompt if file does not exist (using file to set default seach location and extension
% -----------------------------------------------------------------------------------------------------
if ~exist('file','var'), file='*.par'; end
[file_full,ok,mess]=getfilecheck(file);
if ~ok, error(mess), end

% Read data from file
% ---------------------
wout=parObject(file_full);
