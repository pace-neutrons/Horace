classdef gen_sqw_files_job < JobExecutor
    %Class to build sqw files on separtate Matlab session
    %
    % If run in serial, provides methods to generate range of tmp files from
    % range of runfiles
    %
    %
    % $Revision$ ($Date$)
    %
    properties
    end
    
    methods
        function obj = gen_sqw_files_job(varargin)
            obj = obj@JobExecutor(varargin{:});
        end
        function this=do_job(this,varargin)
            % Run jobs of converting from rundata to sqw in separate Matlab
            % session.
            %
            % work together with gen_sqw in multisession mode, expecting
            % parameters, generated there in multisession mode
            %
            %             n_jobs = numel(varargin);
            %             %job_num = this.job_id();
            %             par = cell(n_jobs,1);
            
            % inerface to private sqw function
            [grid_size,urange]=gen_sqw_files_job.runfiles_to_sqw(varargin{:});
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
            % modifies each runfile with single or multiple parameters,
            % defining instrument,sample and optional transformation
            
            par = struct(...
                'runfile',[],'sqw_file_name',[],...
                'grid_size_in',grid_size_in,'urange_in',urange_in);
            run.instrument    = instr;
            run.sample        = samp;
            %
            par.runfile       = run;
            par.sqw_file_name = fname;
        end
        function [grid_size,urange]=runfiles_to_sqw(conversion_par_list)
            % Public interface to private rundata_write_to_sqw function
            % accepting cellarray of structures, with data, defined by 
            % pack_job_pars function
            %
            % Used to run a conversion job on a separate matlab session, spawn from
            % gen_sqw so no checks on parameters validity are performed.
            %
            % Input:
            %  conversion_par_list cellarray of the structures containing the job parameters,
            %                      namely structures fith following fields:
            % ------
            %   run_file        initiated rundata object
            %   sqw_file        full file name of output sqw file
            %   grid_size_in    Scalar or row vector of grid dimensions.
            %   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
            %                   that encloses the whole data range
            %   instrument      object containing instrument information
            %   sample          objects containing sample geometry information
            %
            % Output:
            % -------
            %   grid_size       Actual grid size used (size is unity along dimensions
            %                   where there is zero range of the data points)
            %   urange          Actual range of grid
            %
            
            
            % catch case of single parameters set provided as structure and not an
            % cellarray
            %if ~iscell(conversion_par_list)
            %    conversion_par_list = {conversion_par_list};
            %end
            
            n_files = numel(conversion_par_list);
            run_files    = cell(n_files,1);
            tmp_fnames   = cell(n_files,1);
            
           
            
            grid_size_in = conversion_par_list(1).grid_size_in;
            urange_in = conversion_par_list(1).urange_in;
            for i=1:n_files
                run_files{i}  = conversion_par_list(i).runfile;
                tmp_fnames{i} = conversion_par_list(i).sqw_file_name;
            end
            
            [grid_size,urange] = rundata_write_to_sqw_(run_files,tmp_fnames,...
                grid_size_in,urange_in,false);
        end
    end
end