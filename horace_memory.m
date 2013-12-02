function mem=horace_memory(chunk_size,threads)
% Determine the size of the data chunk to load into memory and the number of threads in mex files
%
%   >> horace_memory(chunk_size,threads)    % set numeric values in each case
%   >> mem = horace_memory;                 % get values
%               mem.chunk_size -- the amximum number of pixels to process at once during cuts
%               mem.threads    -- number of computational threads to use in mex files;
%
% Good default choices are:
%   chunk_size = 1e6 per GB RAM above 4GB, up to a maximum of 1e7
%   threads    = number of processors
%
%
% *** DEPRECATED FUNCTION ***
%   Please set or get the information level directly from the Horace configuration:
%       >> set(hor_config,'mem_chunk_size',chunk_size,'threads',threads);
%       >> [mem.chunk_size,mem.threads]=get(hor_config,'mem_chunk_size','threads');


disp('*** Deprecated function: horace_memory                                       ***')
disp('*** Please set or get the info level directly from the Horace configuration: ***')
disp('***   >> set(hor_config,''mem_chunk_size'',chunk_size,''threads'',threads)       ***')
disp('***   >> [mem.chunk_size,mem.threads]=get(hor_config,''mem_chunk_size'',''threads'')')

if nargin==2
    try
        set(hor_config,'mem_chunk_size',chunk_size,'threads',threads);
    catch ME
        error(ME.message)
    end
elseif nargin~=0
    error('Incorrect number of arguments')
end

if nargout>0 || nargin==0
    [mem.chunk_size,mem.threads]=get(hor_config,'mem_chunk_size','threads');
end
