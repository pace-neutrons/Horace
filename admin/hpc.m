function hpc(varargin)
% function tries to identify if current system is a high performance
% computer and sets up hpc options optimal for current system
%
% based on very limited experience of comparing different systems in ISIS
% recorded on Horace Download and setup web page:
% (http://horace.isis.rl.ac.uk/Download_and_setup)
%
% User should try to identify optimal hpc setting for his particular computer
% and not rely very much on the results, produced by this command, though
% it should be ok to run in on isiscompute. 
%
% Usage:
%>>hpc on    -- enable hpc computing extensions
%>>hpc off   -- disable hpc computing extensions
%>>hpc       -- print current hpc computing extensions value and the values,
%               recommended by this function (very crude estimate)
%
% The meaning of hpc properties this function sets can be described as below:
%   combine_sqw_using: true/false -- should mex extension be used to
%                                      combine tmp files, if such extension
%                                      is availible
%   mex_combine_thread_mode:          0  use mex file for combining and run 
%                                        separate input and output thread
%                                     1  use mex file for combining and in 
%                                        addition to option 0, spawn separate 
%                                        input thread for each input file 
%                                     2  debugging option related to option 1
%                                     3  debugging option related to option 1
%  mex_combine_buffer_size: 65536 -- file buffer used for each input file in mex-file combining
% 
%  build_sqw_in_parallel: 0     -- use separate Matlab sessions when processing input spe or nxspe files
%   parallel_workers_number: 4     -- how many sessions to use.



if nargin>0
    val = varargin{1};
    if strcmpi(val,'on')
        [use_mex_fcr,mex_comb_tmr,mex_comb_bsr,acspr,acp_numr]=find_hpc_options();
        if use_mex_fcr ~= 1
            warning('HPC:using_mex_for_combine',['Setting: ''combine_sqw_using=mex_code'' on this system may decrease ',...
                    'the Horace performance.\nCheck system performance and hpc_config for optimal hpc options']);
        end
        if acspr ~= 1
            warning('HPC:build_sqw_in_parallel',['Setting ''build_sqw_in_parallel=true'' on this system may decrease ',...
                'the Horace performance.\nCheck system performance and hpc_config to select optimal hpc options']);
        end
        
        set(hpc_config,...
        'combine_sqw_using','mex_code','mex_combine_thread_mode',mex_comb_tmr,...
        'mex_combine_buffer_size',mex_comb_bsr,...
        'build_sqw_in_parallel',1,'parallel_workers_number',acp_numr);        
    elseif strcmpi(val,'off')
        hpc = hpc_config;
        hpc.combine_sqw_using = 'matlab';
        hpc.build_sqw_in_parallel = 0;
    else
        fprintf('Unknown hpc option ''%s'', Use ''on'' or ''off'' only\n',varargin{1});
    end
else
    [use_mex_fcr,mex_comb_tmr,mex_comb_bsr,acspr,acp_numr]=find_hpc_options();
    [use_mex_fcc,mex_comb_tmc,mex_comb_bsc,acspc,acp_numc]=get(hpc_config,...
        'combine_sqw_using','mex_combine_thread_mode','mex_combine_buffer_size',...
        'build_sqw_in_parallel','parallel_workers_number');
    
    disp('| computer hpc options    | current val    | recommended val|');
    disp('|-------------------------|----------------|----------------|');
    fprintf('| combine_sqw_using:      | %14s | %14s |\n',use_mex_fcc,use_mex_fcr);
    fprintf('| mex_combine_thread_mode:| %14d | %14d |\n',mex_comb_tmc,mex_comb_tmr);
    fprintf('| mex_combine_buffer_size:| %14d | %14d |\n',mex_comb_bsc,mex_comb_bsr);
    disp('|-------------------------|----------------|----------------|');
    fprintf('| build_sqw_in_parallel:  | %14d | %14d |\n',acspc,acspr);
    fprintf('| parallel_wrkrs_number:  | %14d | %14d |\n',acp_numc,acp_numr);
    disp('-------------------------------------------------------------');
end

function [combine_sqw_using,mex_combine_thread_mode,mex_combine_buffer_size,...
    build_sqw_in_parallel,parallel_workers_number]=find_hpc_options()
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
        % Lasy! need to do better then this, works only on ISIS pc-s
        parallel_workers_number  = 4;
    end
    
end