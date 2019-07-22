function hpc(varargin)
% function tries to identify if current system is a high performance
% computer and sets up hpc options which assumed to be optimal for current system
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
%                                      is available
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
%  parallel_workers_number: 4     -- how many sessions to use.

hpc_options_names = {'combine_sqw_using','mex_combine_thread_mode','mex_combine_buffer_size',...
        'build_sqw_in_parallel','parallel_workers_number'};

if nargin>0
    val = varargin{1};
    if strcmpi(val,'on')
        find_hpc_options(hpc_options_names,'-set_config');        
    elseif strcmpi(val,'off')
        hpc = hpc_config;
        hpc.combine_sqw_using = 'matlab';
        hpc.build_sqw_in_parallel = 0;
    else
        fprintf('Unknown hpc option ''%s'', Use ''on'' or ''off'' only\n',varargin{1});
    end
else
    
    [use_mex_fcr,mex_comb_tmr,mex_comb_bsr,acspr,acp_numr]=find_hpc_options(hpc_options_names);
    [use_mex_fcc,mex_comb_tmc,mex_comb_bsc,acspc,acp_numc]=get(hpc_config,...
        hpc_options_names{:});
    
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

