function [combine_sqw_using,mex_combine_thread_mode,mex_combine_buffer_size,...
    build_sqw_in_parallel,parallel_workers_number]=find_hpc_options()
% method will identify the computer type and return the configuration, most
% appropriate for this computer 
%

if ispc
    combine_sqw_using = 'mex_code';
    mex_combine_thread_mode=0;
    mex_combine_buffer_size=128*1024;
    [~,sys] = memory();
    if sys.PhysicalMemory.Total <  31*1024*1024*1024
        build_sqw_in_parallel = 0;
        parallel_workers_number  = 1;
    elseif sys.PhysicalMemory.Total  >= 31*1024*1024*1024
        if sys.PhysicalMemory.Available >= 0.5*sys.PhysicalMemory.Total
            nproc = idivide(int64(sys.PhysicalMemory.Total),int64(32*1024*1024*1024),'floor');
            if nproc >1
                build_sqw_in_parallel = 1;
                parallel_workers_number  = nproc;
            else
                build_sqw_in_parallel = 0;
                parallel_workers_number  = 2;
            end
        else
            build_sqw_in_parallel = 0;
            parallel_workers_number  = 2;
        end
    end
else
    [nok,mess] = system('lscpu');
    if nok
        %MAC? normal mac does not benefit from hpc
        combine_sqw_using = 'matlab';
        mex_combine_thread_mode =0;
        build_sqw_in_parallel=0;
        parallel_workers_number=2;
        mex_combine_buffer_size = 64*1024;
        return;
    end
    combine_sqw_using = 1;
    rez=strfind(mess,'NUMA node');
    if numel(rez)>2
        hpc_computer = true;
    else
        hpc_computer = false;
    end
    if hpc_computer
        mex_combine_thread_mode = 1;
        mex_combine_buffer_size=2048;
        % assume memory not an issue
        build_sqw_in_parallel = 1;
        parallel_workers_number  = 8;
    else
        mex_combine_thread_mode = 0;
        mex_combine_buffer_size=128*1024;
        
        build_sqw_in_parallel = 1;     
        % Lazy! need to do better then this, works only on ISIS pc-s
        parallel_workers_number  = 4;
    end
    
end