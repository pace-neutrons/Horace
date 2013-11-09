function save (w, file)
% Save a sqw object or array of sqw objects to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%   
%   Note that if w is an array of sqw objects then file must be a cell
%   array of filenames of the same size.
%
% Output:

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get file name - prompting if necessary
if nargin==1 
    file_internal = putfile('*.sqw');
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

log_level= get(hor_config,'horace_info_level');
for i=1:numel(w)
    % Write data to file   x
    if log_level>-1
        disp(['Writing to ',file_internal{i},'...'])
    end
    mess = put_sqw (file_internal{i},w(i).main_header,w(i).header,w(i).detpar,w(i).data);
    if ~isempty(mess); error(mess); end

end
