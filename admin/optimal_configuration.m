function [hc, pc, hpc] = optimal_configuration(varargin)
%% Optimal configuration
% Determine optimal configuration for current machine.

p = inputParser();
p.addParameter('mem_pct', 60, @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
p.addParameter('num_cores', feature('numcores'), ...
              @(x) validateattributes(x, {'numeric'}, {'scalar', 'integer', 'positive'}));
p.addParameter('system_memory', sys_memory(), ...
              @(x) validateattributes(x, {'numeric'}, {'scalar', 'positive'}));
p.addParameter('mpi', 'n/a', ...
              @(x) validatestring(x, {'mpiexec_mpi', ...
                                      'parpool', ...
                                      'herbert', ...
                                      'slurm'}))
p.addParameter('quiet', false, @islognumscalar);
p.addParameter('try_mex', true, @islognumscalar);
p.addParameter('dryrun', false, @islognumscalar);
p.parse(varargin{:});

if ~p.Results.dryrun
    hc = hor_config;
    pc = parallel_config;
    hpc = hpc_config;
else
    hc = struct();
    pc = struct();
    hpc = struct();
end

% Test mex availability
if p.Results.try_mex
    [~, n_errors, can_combine_with_mex] = check_horace_mex();
    use_mex = n_errors == 0;
    if n_errors == 0

        print_info('- MEX acceleration available, using MEX.\n');
        hc.use_mex = true;

        if can_combine_with_mex
            print_info('- Can combine with MEX, enabling.\n');
            hc.combine_sqw_using = 'mex_code';
        end
    else
        print_info('- MEX acceleration not available. Consider building Horace with MEX. \n');
        hc.use_mex = false;
        hc.combine_sqw_using = 'matlab';
    end
else
    hc.use_mex = get(hor_config, 'use_mex');
end

% Test CPU availability

if any(strcmp(p.UsingDefaults, 'num_cores'))
    print_info(['- Discovered %d cores. Using all for calculations.\n', ...
             '  If you believe this number is not correct, ', ...
             'please call this function again with:\n\n', ...
             '  >>> optimal_configuration(''num_cores'', <N>)\n'], p.Results.num_cores);
    pc.parallel_workers_number = p.Results.num_cores;
    pc.threads = 0;
    pc.parallel_threads = 0;
else
    pc.parallel_workers_number = p.Results.num_cores;
    pc.threads = p.Results.num_cores;
    pc.parallel_threads = 1;
end

% Set cluster configuration

% Test slurm availablility
[err_code, ~] = system('squeue');
if err_code == 0
    warning('HORACE:optimal_configuration:slurm_available', ...
            ['- Slurm may be available on your system\n', ...
             '  Horace can only configure for the local node. \n', ...
             '  You may need to manually configure your parallel_config ', ...
             'to take advantage of slurm'])
end

if hc.use_mex
    print_info('- Using C++ MPI as MEX available.\n')
    pc.parallel_cluster = 'mpiexec_mpi';
elseif contains(evalc('ver'), 'Parallel Computing Toolbox')
    print_info('- Using parpool MPI as MATLAB Parallel Computing Toolbox Available.\n')
    pc.parallel_cluster = 'parpool';
else
    print_info('- Using poor-man MPI as no other options available.\n', ...
            '  Consider compiling MEX for better parallel performance.\n')
    pc.parallel_cluster = 'herbert';
end

% Test Memory availability
mem_use = p.Results.mem_pct / 100;

hc.mem_chunk_size = (mem_use * p.Results.system_memory) / ...
    (8 * PixelDataBase.DEFAULT_NUM_PIX_FIELDS);
hpc.mex_combine_buffer_size = (mem_use * p.Results.system_memory) / ...
    (pc.parallel_workers_number);

hc.mem_chunk_size = floor(hc.mem_chunk_size);
hpc.mex_combine_buffer_size = floor(hpc.mex_combine_buffer_size);

if any(strcmp(p.UsingDefaults, 'system_memory'))
    print_info('- Detected %0.1fGb of memory. \n', p.Results.system_memory / (1024.^3))
    print_info('  Using %0.1f%% (%0.1fGb ~ %0.1epix) for page size.\n', ...
            p.Results.mem_pct, ...
            hc.mem_chunk_size * PixelDataBase.DEFAULT_NUM_PIX_FIELDS * 8 / (1024.^3), ...
            hc.mem_chunk_size)
    if hc.use_mex
        print_info('  Using %0.1f%% per worker (%0.1fGb) for MEX combine buffer.\n', ...
                p.Results.mem_pct / pc.parallel_workers_number, ...
                hpc.mex_combine_buffer_size / (1024.^3))
    end

    print_info(['  If you believe this number is not correct, ', ...
             'please call this function again with:\n\n', ...
             '  >>> optimal_configuration(''mem_pct'', <X>, ''system_memory'', <Y>)'])
end
hc.fb_scale_factor = 2;

if p.Results.dryrun && ~p.Results.quiet
    hc
    pc
    hpc
end


function print_info(varargin)
    if p.Results.quiet
        return
    end

    fprintf(varargin{:})
end

end
