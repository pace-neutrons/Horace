classdef gen_tmp_files_jobs < JobExecutor
    %Class to build sqw files on separtate Matlab session
    %
    %
    
    properties
    end
    
    methods
        function obj = gen_tmp_files_jobs(varargin)
            obj = obj@JobExecutor(varargin{:});
        end
        function this=do_job(this,varargin)
            % Run jobs of converting from rundata to sqw in separate Matlab
            % session.
            %
            % work together with gen_sqw in multisession mode, expecting
            % parameters, generated there in multisession mode
            %
            host = sqw();
            %             n_jobs = numel(varargin);
            %             %job_num = this.job_id();
            %             par = cell(n_jobs,1);
            
            % inerface to private sqw function
            [grid_size,urange]=runfiles_to_sqw(host,varargin{:});
            %str = input('enter something to continue:','s');
            %disp(str);
            this = this.return_results(struct('grid_size',grid_size,...
                'urange',urange));
            
        end
    end
    methods(Static)
        function par = pack_job_pars(run,fname,instr,samp,...
                grid_size_in,urange_in)
            % pacj conversion parameters into the form, runfiles_to_sqw
            % understands            
            par = struct(...
                'runfile',[],'sqw_file_name',[],'instrument',[],...
                'sample',[],...
                'grid_size_in',grid_size_in,'urange_in',urange_in);
            par.runfile       = run;
            par.sqw_file_name = fname;
            par.instrument    = instr;
            par.sample        = samp;
        end        
    end
    
end

