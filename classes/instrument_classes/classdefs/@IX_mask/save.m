function save (w, file)
% Save a mask object to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
% Input:
% ------
%   w       Mask object (single object only, not an array)
%   file    [optional] File for output. if none given, then prompted for a file

% Original author: T.G.Perring


% Get file name - prompting if necessary
% --------------------------------------
if ~exist('file','var'), file='*.msk'; end
[file_full,ok,mess]=putfilecheck(file);
if ~ok, error(mess), end

% Write data to file
% ------------------
disp(['Writing mask data to ',file_full,'...'])
[ok,mess] = put_mask (w,file_full);
if ~ok; error(mess); end
