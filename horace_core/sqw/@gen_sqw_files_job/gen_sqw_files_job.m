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
                pix_range_in = common_par.pix_range_in;
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
            [grid_size,data_range,update_runid] = obj.runfiles_to_sqw(run_files,tmp_fnames,...
                grid_size_in,pix_range_in,false);
            % return results
            obj.task_outputs  = struct('grid_size',grid_size,...
                'data_range',data_range,'update_runid',update_runid);
            
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
                data_range = obj.task_outputs.data_range;
                grid_size = obj.task_outputs.grid_size;
                keep_runid= ~obj.task_outputs.update_runid;
                
                for i=1:numel(all_messages)
                    data_range_tmp = all_messages{i}.payload.data_range;
                    grid_size_tmp = all_messages{i}.payload.grid_size;
                    data_range = [min(data_range(1,:),data_range_tmp(1,:));...
                        max(data_range(2,:),data_range_tmp(2,:))];
                    % if any blocks needs runid update, all blocks need runid
                    % update
                    keep_runid = ~all_messages{i}.payload.update_runid && keep_runid;
                    if any(grid_size ~=grid_size_tmp )
                        error('GEN_SQW_FILES_JOB:runtime_error',...
                            'a worker N%d calculates files with grid different from worker N1',...
                            tid_from(i))
                    end
                end
                % return results
                obj.task_outputs = struct('grid_size',grid_size,...
                    'data_range',data_range,'update_runid',~keep_runid);
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
                grid_size_in,pix_range_in)
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
            %   grid_size_in    Scalar or row vector of grid dimensions.
            %   pix_range_in       Range of data grid for output.
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
                'grid_size_in',grid_size_in,'pix_range_in',pix_range_in);
            %
            loop_par = cell2struct({runfiles;tmp_files},...
                {'runfile','sqw_file_name'});
        end
        %
        function [grid_size,data_range,update_runlabels]=...
                runfiles_to_sqw(run_files,tmp_fnames,...
                grid_size_in,pix_db_range,varargin)
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
            %   pix_db_range    Range of pixels grid to rebin pixels on.
            %                   If not given, then uses smallest hypercuboid
            %                   that encloses the whole actual data range.
            % optional:
            %   write_banner    =true then write banner; =false then done (no banner will be
            %                   written anyway if the output logging level is not high enough)
            %
            % Output:
            % -------
            % grid_size       -  Actual grid size used (size is unity along dimensions
            %                    where there is zero range of the data points)
            % data_range       -  Actual range of grid, should be different from
            %                    pix_range_in only if pix_range_in is not provided
            % update_runlabels -  if true, each run-id for every runfile has to be
            %                    modified as some runfiles have the same run-id(s).
            %                    This possible e.g. in "replicate" mode.
            
            %
            [grid_size,data_range,update_runlabels] = ...
                rundata_write_to_sqw_(run_files,tmp_fnames,...
                grid_size_in,pix_db_range,varargin{:});
        end
        
    end
end

