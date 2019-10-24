function save (w, file)
% Save a sqw object to file
%
%   >> save_sqw (w)              % prompt for file
%   >> save_sqw (w, file)        % give file
%
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%
% Output:

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

extension='d1d';

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

% Get file name - prompting if necessary
if nargin==1 
    file_internal = putfile(['*.',extension]);
    if (isempty(file_internal))
        error ('No file given')
    end
else
    [file_internal,mess]=putfile_horace(file);
    if ~isempty(mess)
        error(mess)
    end
end
if ~iscellstr(file_internal)
    file_internal=cellstr(file_internal);
end
if numel(file_internal)~=numel(w)
    error('Number of data objects in array does not match number of file names')
end

% Write data to file
save(sqw(w),file_internal)
