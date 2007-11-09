function status = save_sqw (sqw,file)
% Save a full sqw data structure to file
%
%   >> save_sqw (sqw)              % prompt for file
%   >> save_sqw (sqw, file)        % give file
%
% Input:
%   sqw         sqw data structure
%   file        [optional] File for output. if none given, then prompted for a file
%
% Output:

% T.G.Perring 13 August 2007


% Check the input variable
if isstruct(sqw)
    mess = sqw_checkfields (sqw);
    if ~isempty(mess)
        error ('Input structure does not have a valid sqw dataset structure')
    end
    if ~strcmpi(sqw_type(sqw.data),'a')
        error('sqw data structure does not contain pixel information - cannot save cut')
    end
else
    error ('Input data source must be a sqw data structure')
end

% Get file name - prompting if necessary
if (nargin==1)
    file_internal = genie_putfile('*.sqw');
    if (isempty(file_internal))
        error ('No file given')
    end
elseif (nargin==2)
    file_internal = file;
end

% Write data to file
disp(['Writing sqw data structure to ',file_internal,'...'])
mess = write_sqw (file_internal,sqw.main_header,sqw.header,sqw.detpar,sqw.data);
if ~isempty(mess); error(mess); end
