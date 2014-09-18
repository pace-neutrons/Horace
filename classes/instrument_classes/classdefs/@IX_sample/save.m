function save(w,file)
% Save object or array of objects of class type to binary file. Inverse of read.
%
%   >> save (w)           % prompts for file to write to
%   >> save (w, file)     % write to named file

% Method independent of class type

% Get file name - prompting if necessary
% --------------------------------------
if ~exist('file','var'), file='*.mat'; end
[file_full,ok,mess]=putfilecheck(file);
if ~ok, error(mess), end

% Write data to file
% ------------------
save(file_full,'w','-mat')  % enforce matlab binary format regardless of extension
