classdef gen_sqw_files_job < JobExecutor
    %Class to build sqw files on separtate Matlab session
    %
    % If run in serial, provides methods to generate range of tmp files from
    % range of runfiles
    %
    %
    % $Revision$ ($Date$)
    %
    properties(Access = private)
        is_finished_  = false;
    end
    
    methods
        function obj = gen_sqw_files_job(varargin)
            obj = obj@JobExecutor();
        end
        function this=do_job(this)
            % Run jobs of converting from rundata to sqw in separate Matlab
            % session.
            %
            % work together with gen_sqw in MPI mode, expecting
            % parameters, generated there in multisession mode
            %
            
            % unpack input data transferred though MPI channels for
            % runfiles_to_sqw to understand.
            
            common_par = this.common_data_;
            loop_par   = this.loop_data_;
            
            grid_size_in = common_par.grid_size_in;
            urange_in = common_par.urange_in;
            
            if isstruct(loop_par)
                run_files  = loop_par.runfile;
                if ~iscell(run_files)
                    run_files   = {run_files };
                end
                tmp_fnames = loop_par.sqw_file_name;
                if ~iscell(tmp_fnames)
                    tmp_fnames = {tmp_fnames};
                end
                n_files    = numel(run_files);
                
            else
                n_files    = numel(loop_par);
                run_files  = cell(n_files,1);
                tmp_fnames = cell(n_files,1);
                for i=1:n_files
                    run_files{i}  = loop_par(i).runfile;
                    tmp_fnames{i} = loop_par(i).sqw_file_name;
                    
                end
            end
            if isfield(common_par,'sample')
                for i=1:n_files
                    run_files{i}.sample     = common_par.sample;
                    run_files{i}.instrument = common_par.instrument;
                end
            end
            % Do conversion
            [grid_size,urange] = this.runfiles_to_sqw(run_files,tmp_fnames,...
                grid_size_in,urange_in,false);
            % return results
            this.task_outputs  = struct('grid_size',grid_size,...
                'urange',urange);
            
        end
        function  obj=reduce_data(obj)
            obj.is_finished_ = true;
        end
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end
        function [ok,mess] =finish_task(obj,varargin)
            % overloaded finish_task function, which calculates common
            % urange among the uranges, processed by each worker
            % instead of simply returning message, containing cellarray of
            % ranges for each worker.
            
            if nargin > 1
                [ok,mess] = finish_task@JobExecutor(obj,...
                    varargin{1},@average_range_process_function_);
            else
                [ok,mess] = finish_task@JobExecutor(obj,...
                    [],@average_range_process_function_);
            end
        end
        
    end
    methods(Static)
        function [common_par,loop_par] = pack_job_pars(runfiles,tmp_files,...
                instr,sample, grid_size_in,urange_in)
            % helper function packs gen_sqw  input data into the form, suitable
            % for jobDispatcher to split berween workers and to prepare
            % to transmit to this class instance on a separated Matlab
            % worker, where unpacked, these data become the input for
            % do_job method.
            %
            % Inputs:
            % ------
            %   runfiles        cellarry of initiated rundata objects to
            %                   process
            %   tmp_files       list of full file names of output sqw (tmp)
            %                   files to generate
            %   instr           object containing instrument information.
            %                   Single instrument at the moment
            %   sample          objects containing sample geometry information
            %   grid_size_in    Scalar or row vector of grid dimensions.
            %   urange_in       Range of data grid for output.
            %
            % Outputs:
            % -------
            % common_par        structure containing all common parameters
            %                   used in conversion to sqw (tmp) files in
            %                   the form, do_job method of this class would
            %                   understand
            % loop_par          cellarray or array of structures,
            %                   describing each file to transform into sqw
            %                   (tmp)
            
            common_par = struct(...
                'grid_size_in',grid_size_in,'urange_in',urange_in);
            % simplify -- no instrument, no sample
            if ~isempty(instr) && (isstruct(instr(1)) && ~isempty(fieldnames(instr(1))))
                if numel(instr) == numel(sample) && (numel(sample) ==numel(runfiles ))
                    n_files = numel(runfiles);
                    for i=1:n_files
                        if iscell(runfiles)
                            runfiles{i}.sample     = sample(i);
                            runfiles{i}.instrument = instr(i);
                        else
                            runfiles(i).sample     = sample(i);
                            runfiles(i).instrument = instr(i);
                        end
                    end
                    
                else
                    common_par.instrument    = instr(1);
                    common_par.sample        = sample(1);
                    
                end
            end
            %
            loop_par = cell2struct({runfiles;tmp_files},...
                {'runfile','sqw_file_name'});
        end
        %
        function [grid_size,urange]=runfiles_to_sqw(run_files,tmp_fnames,...
                grid_size_in,urange_in,varargin)
            % Public interface to private rundata_write_to_sqw_ function
            % which do actually converts all input runfiles into list of
            % sqw (tmp) files.
            %
            % Used to run a conversion job on a separate matlab session, spawn from
            % gen_sqw so no checks on parameters validity are performed.
            %
            % Input:
            % ------
            %   run_file        initiated rundata object(s) containing
            %                   initiated instrument and sample
            %   sqw_file        full file name of output sqw file
            %   grid_size_in    Scalar or row vector of grid dimensions.
            %   urange_in       Range of data grid for output. If not given, then uses smallest hypercuboid
            %                   that encloses the whole data range
            % optional:
            %   write_banner    =true then write banner; =false then done (no banner will be
            %                   written anyway if the output logging level is not high enough)
            %
            % Output:
            % -------
            %   grid_size       Actual grid size used (size is unity along dimensions
            %                   where there is zero range of the data points)
            %   urange          Actual range of grid
            %
            [grid_size,urange] = rundata_write_to_sqw_(run_files,tmp_fnames,...
                grid_size_in,urange_in,varargin{:});
        end
        
    end
end
