classdef accumulate_headers_job < JobExecutor
    % Class to combine multple sqw(tmp) file headers in parallel
    %
    % If run in serial, provides methods to generate range of tmp files from
    % range of runfiles
    %
    %
    % $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
    %
    
    properties
        s_accum;
        e_accum;
        npix_accum;
    end
    properties(Access=protected)
        is_finished_ = false;
    end
    
    methods
        function obj = accumulate_headers_job()
            obj = obj@JobExecutor();
        end
        
        function obj=do_job(obj)
            % Run main accumulation for a worker.
            %
            
            % unpack input data transferred though MPI channels for
            % runfiles_to_sqw to understand.
            %common_par = this.common_data_;
            sqw_loaders = obj.loop_data_;
            for i=1:numel(sqw_loaders)
                sqw_loaders{i} = sqw_loaders{i}.activate();
            end
            
            % Do accumulation
            [obj.s_accum,obj.e_accum,obj.npix_accum] = obj.accumulate_headers(sqw_loaders);
            
        end
        function  obj=reduce_data(obj)
            % method to summarize all particular data from all workers.
            mf = obj.mess_framework;
            if isempty(mf) % something wrong, framework deleted
                error('ACCUMULATE_HEADERS_JOB:runtime_error',...
                    'MPI framework is not initialized');
            end
            
            if mf.labIndex == 1
                all_messages = mf.receive_all('all','data');
                for i=1:numel(all_messages)
                    obj.s_accum = obj.s_accum + all_messages{i}.payload.s;
                    obj.e_accum = obj.e_accum + all_messages{i}.payload.e;
                    obj.npix_accum = obj.npix_accum+ all_messages{i}.payload.npix;
                end
                % return results
                obj.task_outputs = struct('s',obj.s_accum,...
                    'e',obj.e_accum,'npix',obj.npix_accum);
            else
                %
                the_mess = aMessage('data');
                the_mess.payload = struct('s',obj.s_accum,...
                    'e',obj.e_accum,'npix',obj.npix_accum);
                
                [ok,err]=mf.send_message(1,the_mess);
                if ok ~= MESS_CODES.ok
                    error('ACCUMULATE_HEADERS_JOB:runtime_error',err);
                end
                obj.task_outputs = [];
            end
            obj.is_finished_ = true;
        end
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end
    end
    methods(Static)
        function [s_accum,e_accum,npix_accum]=accumulate_headers(loaders)
            % method reads all image data from all sqw files represented by
            % initialized file loaders and accumulates these data for
            % further usage as image of combined sqw file.
            %
            mpi_obj= MPI_State.instance();
            running_mpi = mpi_obj.is_deployed;
            
            nfiles = numel(loaders);
            if ~running_mpi
                % initialise completion message reporting
                mess_completion(nfiles,5,0.1)
            end
            
            
            for i=1:nfiles
                % get signal error and npix information
                bindata = loaders{i}.get_se_npix();
                if i==1
                    s_accum = (bindata.s).*(bindata.npix);
                    e_accum = (bindata.e).*(bindata.npix).^2;
                    npix_accum = bindata.npix;
                else
                    s_accum = s_accum + (bindata.s).*(bindata.npix);
                    e_accum = e_accum + (bindata.e).*(bindata.npix).^2;
                    npix_accum = npix_accum + bindata.npix;
                end
                clear bindata
                %
                if running_mpi
                    mpi_obj.do_logging(i,nfiles,[],[]);
                else
                    mess_completion(i)
                end
            end
            %
            if ~running_mpi
                mess_completion
            end
        end
        function [main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
                read_input_headers(infiles)
            % function prepares input headers data for write_nswq_to_sqw
            % procedure.
            % Inputs:
            % infiles -- list of input tmp files to combine using
            %             write_nswq_to_sqw 
            % Outputs:  
            %                 (see sqw file format for the details of the
            %                 fields);
            % main_header  -- cellarray of main headers for all contributed
            %                 infiles
            % header       -- cellarray of headers for all contributed
            %                 infiles
            % datahdr      -- cellarray of data headers for all contributed
            %                 infiles
            % pos_npixstart -- for binary sqw files, array of locations of
            %                  npix information in contributed infiles
            % pos_pixstart  -- for binary sqw files, array of locations of
            %                  pix information in contributed infiles
            % npixtot       -- array of number of pixels per each infile
            % det           -- detectors information (must be the same for
            %                  all contributed infiles)
            % ldrs          -- cellarray of correspondent loaders, to read data from
            %                  each infile. The loaders are initalized i.e.
            %                  associated with correspondedn infile
            [main_header,header,datahdr,pos_npixstart,pos_pixstart,npixtot,det,ldrs] = ...
                read_input_headers_(infiles);
        end
        
        function [common_par,loop_par] = pack_job_pars(sqw_loaders)
            % Pack the accumulating job parameters into the form, suitable
            % for division between workers and MPI transfer.
            common_par = [];
            loop_par = cell(size(sqw_loaders));
            for i=1:numel(sqw_loaders)
                sqw_loaders{i} = sqw_loaders{i}.deactivate();
                loop_par{i} = sqw_loaders{i};
            end
        end
    end
end

