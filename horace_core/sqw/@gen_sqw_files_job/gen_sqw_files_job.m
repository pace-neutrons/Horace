classdef gen_sqw_files_job < JobExecutor
    %Class to build sqw files on separate Matlab session
    %
    % If run in serial, provides methods to generate range of tmp files from
    % range of runfiles
    %
    properties(Access = private)
        is_finished_  = false;
    end
    
    methods
        function obj = gen_sqw_files_job(varargin)
            obj = obj@JobExecutor();
        end
        function obj=do_job(obj)
            % Run jobs of converting from rundata to sqw in separate Matlab
            % session.
            %
            % work together with gen_sqw in MPI mode, expecting
            % parameters, generated there in multisession mode
            %
            
            % unpack input data transferred though MPI channels for
            % runfiles_to_sqw to understand.
            
            common_par = obj.common_data_;
            loop_par   = obj.loop_data_;
            
            try
                grid_size_in = common_par.grid_size_in;
                urange_in = common_par.urange_in;
            catch ME
                mess =  matlab.unittest.diagnostics.ConstraintDiagnostic.getDisplayableString(common_par);
                mex1 = MException('GEN_SQW_FILES_JOB:invalid_common_par',mess);
                ME = ME.addCause(mex1);
                rethrow(ME);
            end
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
            [grid_size,urange] = obj.runfiles_to_sqw(run_files,tmp_fnames,...
                grid_size_in,urange_in,false);
            % return results
            obj.task_outputs  = struct('grid_size',grid_size,...
                'urange',urange);
            
        end
        %
        function  obj=reduce_data(obj)
            mf = obj.mess_framework;
            if isempty(mf) % something wrong, framework deleted
                error('GEN_SQW_FILES_JOB:runtime_error',...
                    'MPI framework is not initialized');
            end
            if mf.labIndex == 1
                [all_messages,tid_from] = mf.receive_all('all','data');
                urange = obj.task_outputs.urange;
                grid_size = obj.task_outputs.grid_size;
                
                for i=1:numel(all_messages)
                    urange_tmp = all_messages{i}.payload.urange;
                    grid_size_tmp = all_messages{i}.payload.grid_size;
                    urange = [min(urange(1,:),urange_tmp(1,:));...
                        max(urange(2,:),urange_tmp(2,:))];
                    if any(grid_size ~=grid_size_tmp )
                        error('GEN_SQW_FILES_JOB:runtime_error',...
                            'a worker N%d calculates files with grid different from worker N1',...
                            tid_from(i))
                    end
                end
                % return results
                obj.task_outputs = struct('grid_size',grid_size,...
                    'urange',urange);
            else
                %
                the_mess = DataMessage(obj.task_outputs);
                %
                [ok,err]=mf.send_message(1,the_mess);
                if ok ~= MESS_CODES.ok
                    error('ACCUMULATE_HEADERS_JOB:runtime_error',err);
                end
                obj.task_outputs = [];
            end
            
            obj.is_finished_ = true;
        end
        %
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end
    end
    methods(Static)
        function [common_par,loop_par] = pack_job_pars(runfiles,tmp_files,...
                instr,sample, grid_size_in,urange_in)
            % helper function packs gen_sqw  input data into the form, suitable
            % for jobDispatcher to split between workers and to prepare
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
            % Used to run a conversion job on a separate Matlab session, spawn from
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

