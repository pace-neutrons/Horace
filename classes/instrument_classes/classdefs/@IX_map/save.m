function save (w, file)
% Save a mapping object to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
% Input:
% ------
%   w       Mapping object (single object only, not an array)
%   file    [optional] File for output. if none given, then prompted for a file

% Original author: T.G.Perring


% Get file name - prompting if necessary
% --------------------------------------
if ~exist('file','var'), file='*.map'; end
[file_full,ok,mess]=putfilecheck(file);
if ~ok, error(mess), end

% Write data to file
% ------------------
disp(['Writing mapping data to ',file_full,'...'])
[ok,mess] = put_map (w,file_full);
if ~ok; error(mess); end
