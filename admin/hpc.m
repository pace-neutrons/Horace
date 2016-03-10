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
%   use_mex_for_combine: true/false -- should mex extension be used to
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
%  accum_in_separate_process: 0     -- use separate Matlab sessions when processing input spe or nxspe files
%   accumulating_process_num: 4     -- how many sessions to use.



if nargin>0
    val = varargin{1};
    if strcmpi(val,'on')
        [use_mex_fcr,mex_comb_tmr,mex_comb_bsr,acspr,acp_numr]=find_hpc_options();
        if use_mex_fcr ~= 1
            warning('HPC:using_mex_for_combine',['Setting: ''use_mex_for_combine=true'' on this system may decrease ',...
                    'the Horace performance.\nCheck system performance and hor_config for optimal hpc options']);
        end
        if acspr ~= 1
            warning('HPC:accum_in_separate_process',['Setting ''accum_in_separate_process=true'' on this system may decrease ',...
                'the Horace performance.\nCheck system performance and hor_config to select optimal hpc options']);
        end
        
        set(hor_config,...
        'use_mex_for_combine',1,'mex_combine_thread_mode',mex_comb_tmr,...
        'mex_combine_buffer_size',mex_comb_bsr,...
        'accum_in_separate_process',1,'accumulating_process_num',acp_numr);        
    elseif strcmpi(val,'off')
        hc = hor_config;
        hc.use_mex_for_combine = 0;
        hc.accum_in_separate_process = 0;
    else
        fprintf('Unknown hpc option ''%s'', Use ''on'' or ''off'' only\n',varargin{1});
    end
else
    [use_mex_fcr,mex_comb_tmr,mex_comb_bsr,acspr,acp_numr]=find_hpc_options();
    [use_mex_fcc,mex_comb_tmc,mex_comb_bsc,acspc,acp_numc]=get(hor_config,...
        'use_mex_for_combine','mex_combine_thread_mode','mex_combine_buffer_size',...
        'accum_in_separate_process','accumulating_process_num');
    
    disp('| computer hpc options    | current val    | recommended val|');
    disp('|-------------------------|----------------|----------------|');
    fprintf('| use_mex_for_combine:    | %14d | %14d |\n',use_mex_fcc,use_mex_fcr);
    fprintf('| mex_combine_thread_mode:| %14d | %14d |\n',mex_comb_tmc,mex_comb_tmr);
    fprintf('| mex_combine_buffer_size:| %14d | %14d |\n',mex_comb_bsc,mex_comb_bsr);
    disp('|-------------------------|----------------|----------------|');
    fprintf('| accum_in_sep_process:   | %14d | %14d |\n',acspc,acspr);
    fprintf('| accum_process_num:      | %14d | %14d |\n',acp_numc,acp_numr);
    disp('-------------------------------------------------------------');
end

function [use_mex_for_combine,mex_combine_thread_mode,mex_combine_buffer_size,...
    accum_in_separate_process,accumulating_process_num]=find_hpc_options()
if ispc
    use_mex_for_combine = 0;
    mex_combine_thread_mode=0;
    mex_combine_buffer_size=64*1024;
    [~,sys] = memory();
    if sys.PhysicalMemory.Total <  31*1024*1024*1024
        accum_in_separate_process = 0;
        accumulating_process_num  = 1;
    elseif sys.PhysicalMemory.Total  >= 31*1024*1024*1024
        if sys.PhysicalMemory.Available >= 0.5*sys.PhysicalMemory.Total
            nproc = idivide(int64(sys.PhysicalMemory.Total),int64(32*1024*1024*1024),'floor');
            if nproc >1
                accum_in_separate_process = 1;
                accumulating_process_num  = nproc;
            else
                accum_in_separate_process = 0;
                accumulating_process_num  = 2;
            end
        else
            accum_in_separate_process = 0;
            accumulating_process_num  = 2;
        end
    end
else
    [nok,mess] = system('lscpu');
    if nok
        %MAC? normal mac does not benifit from hpc
        use_mex_for_combine = 0;
        mex_combine_thread_mode =0;
        accum_in_separate_process=0;
        accumulating_process_num=2;
        mex_combine_buffer_size = 64*1024;
        return;
    end
    use_mex_for_combine = 1;
    rez=strfind(mess,'NUMA node');
    if numel(rez)>2
        hpc_computer = true;
    else
        hpc_computer = false;
    end
    if hpc_computer
        mex_combine_thread_mode = 2;
        mex_combine_buffer_size=1024;
        % assume memory not an issue
        accum_in_separate_process = 1;
        accumulating_process_num  = 8;
    else
        mex_combine_thread_mode = 0;
        mex_combine_buffer_size=64*1024;
        
        accum_in_separate_process = 1;     
        % Lasy! need to do better then this, works only on ISIS pc-s
        accumulating_process_num  = 4;
    end
    
end