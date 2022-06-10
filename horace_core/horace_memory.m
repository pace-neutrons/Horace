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

elseif nargin ~= 0 && nargin ~= 2
    error('HORACE:horace_memory:invalid_argument', 'Incorrect number of arguments')
end

disp('*** Deprecated function: horace_memory                                       ***')
disp('*** Please set or get the info level directly from the Horace configuration: ***')
disp('***   >> set(hor_config,''mem_chunk_size'',chunk_size)                       ***')
disp('***   >> set(parallel_config,''threads'',threads)                            ***')
disp('***   >> mem.chunk_size = get(hor_config,''mem_chunk_size'')                 ***')
disp('***   >> mem.threads    = get(parallel_config,''threads'')                   ***')

if nargin==2
    set(hor_config,'mem_chunk_size',chunk_size);
    set(parallel_config,'threads',threads);
end

if nargout > 0
    mem.chunk_size = get(hor_config,'mem_chunk_size');
    mem.threads    = get(parallel_config,'threads');
end
