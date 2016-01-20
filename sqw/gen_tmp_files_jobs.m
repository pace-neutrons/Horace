classdef gen_tmp_files_jobs < JobDispatcher
    %Class to build sqw files on separtate Matlab session
    %
    %
    
    properties
    end
    
    methods
        function obj = gen_tmp_files_jobs()
            obj = obj@JobDispatcher();
        end
        function this=do_job(this,varargin)
            % Run jobs of converting from rundata to sqw in separate Matlab
            % session.
            %
            % work together with gen_sqw in multisession mode, expecting
            % parameters, generated there in multisession mode
            %
            host = sqw();
            n_jobs = numel(varargin);
            %job_num = this.job_id();
            par = cell(n_jobs,1);
            for ji = 1:n_jobs
                par{ji} = JobDispatcher.restore_param(varargin{ji});
            end
            % inerface to private sqw function
            [grid_size,urange]=runfiles_to_sqw(host,par);
            %str = input('enter something to continue:','s');
            %disp(str);
            this = this.set_outputs(struct('grid_size',grid_size,...
                'urange',urange));
            
        end
        
    end
    
end

