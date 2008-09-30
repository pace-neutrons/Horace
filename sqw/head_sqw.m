function data = head_sqw (data_source)
% Displays header information for an sqw data structure or sqw binary file
% Read data from a file containing sqw data. Will be a full sqw data structure, or Horace dnd (n=0...4) object
%
%   >> data = head_sqw (sqw)    % sqw data structure
%   >> data = head_sqw (file)   % sqw binary file

% T.G.Perring 13 August 2007

if nargin==1 && isstruct(data_source)
    mess = sqw_checkfields (data_source);
    if ~isempty(mess)
        error ('Input structure does not have a valid sqw dataset structure')
    end
    sqw_to_dnd(data_source)
else
    if nargin==1 && isa_size(data_source,'row','char')
        if (exist(data_source,'file')==2)
            file_internal = data_source;
        else
            file_internal = genie_getfile(data_source);
        end
    elseif nargin==0
        file_internal = genie_getfile;
    else
        error ('Input data source must be a sqw data structure')
    end
    if (isempty(file_internal))
        error ('No file given')
    else
        read_sqw(file_internal)
    end
end
