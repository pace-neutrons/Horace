classdef combine_sqw_pix_job < JobExecutor
    % combine pixels located in multiple sqw files into continuous pixels block
    % located in a single sqw file
    %
    %
    % Given range of tmp files with pixels distributed in bins
    %
    properties(Dependent)
        % the way of splitting combine job among workers.
        % Two modes are available: 1 -- Single writer/combiner and multiple
        % readers and 2 - writer-combiner-multiple readers
        combine_mode
    end
    properties(Access = protected)
        is_finished_  = false;
        finalizer_ =[];
        open_files_id_ = [];
        
        % property to store pixels, which have not yet received information
        % from all contributed bins (files)
        pix_cache_ ;
        
        % Print debugging information if necessary
        h_log_file;
        h_log_file_closer;
        DEBUG = false;
        % the initial information about the bins and pixels to process
        pix_combine_info_;
        
        % array of open file handles, for source files
        fid_
        %
        %  the holder of the procedure, used to close the input
        %  files at job completeon/class destruction
        fid_closer_
        % open file handle, for target file
        fout_
        %
        %  the holder of the procedure, used to close the input
        %  files at job completeon/class destruction
        fout_closer_
        
        %
        % the structure, used as the payload for a data messages
        % transmitted between jobs and containing pixels and bins
        % information used in combining
        mess_struct_
        %
        combine_mode_ = 1;
        %
        % The number of auxiliary workers, not participating in reading data
        % It can be 1 single writer-combiner/mutliple readers
        % or 2 (1 writer, 1 combiner/multiple readers)
        reader_id_shift_ = 1;
        
    end
    
    methods
        function obj = combine_sqw_pix_job()
            obj = obj@JobExecutor();
            % the data message payload, containing pixel information
            obj.mess_struct_ = struct(...
                'npix',0,... % number of pixels in message
                'n_source',0 ,...     % number of reader in the list or readers prepared data message
                'bin_range',[0,0],... % min-max numbers of bins the pixel data contributes to
                'pix_data',[],...     % the pixel data block itself.
                'bin_edges',[],...    % array of bin edges, every number pointing to the postion in the pix_data, where this bin data are located
                'last_bin_completed',true); % boolean, indicating if the
            % message contains all data for last bin in its range,
            % or next message will bring additional data for this bin.
        end
        function [obj,mess]=init(obj,fbMPI,intercom_class,InitMessage,varargin)
            % Overloads parent's init by adding the initialization
            % routines, specific for combibe_sqw_pix_job
            %
            % All inputs are inhereted from parent init
            %
            % inputs and files:
            % fbMPI               -- the initialized instance of file-based
            %                        messages framework, used for messages
            %                        exchange between worker and the control node.
            %                        Depending on the used framework and job,
            %                        this class can be used for communications
            %                        between workers too.
            % intercom_class     --  the class, providing MPI or pseudo MPI
            %                         communications between workers
            % InitMessage         -- The message with information necessary
            %                        to ititiate the job itself
            % Optional:
            % is_tested           -- if there, indicates, that the
            %                        framework is tested. Not used for
            %                        combine_sqw_pix job.
            %
            % returns:
            % obj          initialized combibe_sqw_pix_job object
            % mess         if not empty, the reason for failure
            %
            % On success, also:
            % ReduceSend 'started' message to a control node (its node 1 over MPI
            % framework for workers with labID > 1 and node 0 over
            % FileBased for worker with labID ==  1)
            %
            [obj,mess]=init@JobExecutor(obj,fbMPI,intercom_class,InitMessage);
            if obj.DEBUG
                fname = sprintf('comb_sqw_N%d_log.log',obj.labIndex);
                obj.h_log_file = fopen(fname,'w');
                obj.h_log_file_closer = onCleanup(@()fclose(obj.h_log_file));
            else
                obj.h_log_file = false;
            end
        end
        %
        function obj = init_reader_task(obj)
            % initialize reader job, namely
            % open or reopen all input files and
            % specify the procedure to close these files at the end of the
            % job.
            %
            % Reopen the files
            obj.fid_ = verify_and_reopen_input_files_(obj);
            
            % Always close opened files on the procedure completion
            obj.fid_closer_  =  onCleanup(@()fcloser_(obj.fid_));  %
        end
        %
        function obj = init_writer_task(obj)
            % initialize writer job, namely
            % open target sqw file, define pixel combine cache for
            % 1w-Nr configuration and
            % specify the procedure to close these files at the end of the
            % job.
            %
            % open target file for writing
            obj = init_writer_job_(obj);
            
            % Always close opened files on the procedure completion
            obj.fout_closer_  =  onCleanup(@()fcloser_(obj.fout_));  %
        end
        function obj = init_combiner_task(obj)
            % initialize job, which sorts and combines pixels according to
            % bins
            % open target file for writing
            obj = init_combiner_job_(obj);
        end
        
        
        
        function obj=do_job(obj)
            % main executable code, running on each parallel worker.
            %
            % get the information, common for all parallel workers.
            common_par      = obj.common_data_;
            % receive block of the, specific for the given workers
            obj.pix_combine_info_ = obj.loop_data_{1};
            obj.combine_mode = common_par.combine_mode;
            
            h_log_fl = obj.ext_log_fh;
            if isempty(h_log_fl)
                h_log_fl  = false;
            end
            
            if obj.labIndex == 1 % writer lab
                obj = obj.init_writer_task();
                
                if obj.combine_mode ==2
                    n_received = receive_combined_write_output_(obj,common_par,h_log_fl);
                else
                    n_received = receive_data_write_output_(obj,common_par,h_log_fl);
                end
                obj.task_outputs = n_received;
                
                obj.fout_closer_ = [];
            else
                if obj.combine_mode ==2 && obj.labIndex == 2
                    % combiner lab
                    obj = obj.init_combiner_task();
                    n_combined = receive_combine_send_to_writer_(obj,common_par,h_log_fl);
                    
                    obj.task_outputs = n_combined;
                else
                    % reader labs
                    obj = obj.init_reader_task();
                    
                    n_sent = read_inputs_send_to_writer_(obj,common_par,h_log_fl);
                    obj.task_outputs = n_sent;
                    % close all open files
                    obj.fid_closer_ = [];
                end
            end
            %
            obj.is_finished_ = true;
        end
        %
        function obj=reduce_data(obj)
            obj.is_finished_  = true;
        end
        %
        function ok = is_completed(obj)
            ok = obj.is_finished_;
        end
        function cm = get.combine_mode(obj)
            cm = obj.combine_mode_;
        end
        function obj = set.combine_mode(obj,val)
            if ~isnumeric(val) || val<1 || val>2
                error('COMBIME_SQW:invalid_argument',...
                    ' combine mode has to be numeric value 1 or 2. Got %s',...
                    (evalc('disp(val)')));
            end
            obj.combine_mode_ = val;
            if obj.combine_mode_ == 1
                obj.reader_id_shift_ = 1;
            else
                obj.reader_id_shift_ = 2;
            end
        end
        % submethods necessary for main workflow
        %------------------------------------------------------------------
        function write_npix_to_pix_blocks(obj,fout,pix_out_position,pix_comb_info)
            % take pixels from the contributing files and place them into final sqw
            % file pixels block.
            %
            % Serial implementation of parallel job
            %
            % Inputs:
            % fout             -- filehandle or filename of target sqw file
            % pix_out_position -- the position where pixels should be located in the
            %                     target binary file
            % pix_comb_info    -- the class containing the information about the input
            %                     files to combine, namely the fields:
            %
            %   infiles         Cell array of file names, or array of file identifiers of open files, from
            %                   which to accumulate the pixel information
            %   pos_npixstart   Position (in bytes) from start of file of the start of the field npix
            %   pos_pixstart    Position (in bytes) from start of file of the start of the field pix
            %   npix_cumsum     Accumulated sum of number of pixels per bin across all the files
            %   run_label       Indicates how to re-label the run index (pix(5,...)
            %                       'fileno'        relabel run index as the index of the file in the list infiles
            %                       'nochange'      use the run index as in the input file
            %                        numeric array  offset run numbers for ith file by ith element of the array
            %                   This option exists to deal with three limiting cases:
            %                    (1) The run index is already written to the files correctly indexed into the header
            %                       e.g. as when temporary files have been written during cut_sqw
            %                    (2) There is one file per run, and the run index in the header block is the file
            %                       index e.g. as in the creating of the master sqw file
            %                    (3) The files correspond to several runs in general, which need to
            %                       be offset to give the run indices into the collective list of run parameters
            %
            % As the result -- writes combined pixels block to the ouput sqw file.
            
            write_npix_to_pix_blocks_(obj,fout,pix_out_position,pix_comb_info);
        end
        %
        function npix_section = read_npix_block(obj,ibin_start,nbin_buf_size)
            % Inputs:
            % ibin_start -- first bin to process
            % nbin_buf_size -- number of bins to read and process
            %
            % Uses pix_combine info, containing locations of the npix blocks in all
            % input files and defined as property of the cobine_pix job
            npix_section = read_npix_block_(obj,ibin_start,nbin_buf_size);
        end
        %
        function [pix_section,pos_pixstart]=...
                read_pix_for_nbins_block(obj,pos_pixstart,npix_per_bin)
            % take range of open input files and
            % read pixels blocks corresponding to the input bins block
            % provided.
            % Inputs:
            %
            % pos_pixstart -- binary positions of the start of the pixels
            %                 block to process
            % npix_per_bin -- 2D array of numbers of pixels per bin per file
            %                 within selected bin block
            [pix_section,pos_pixstart]=...
                read_pix_for_nbins_block_(obj,pos_pixstart,npix_per_bin);
            
        end
        %
        %
        function [npix_section,npix_in_bins,ibin_end]=get_npix_section(obj,ibin_start,ibin_max,varargin)
            % Fill a structure with sections of the npix arrays for all the input files. The positions of the
            % pointers in the input files is left at the positions on entry (the algorithm requires them to be moved, but returns
            % them at the end of the operation)
            %
            %   >> [npix_section,ibin_end,mess]=get_npix_section(ibin_start,ibin_max)
            %
            % Input:
            % ------
            %   ibin_start      Get section starting with this bin number
            %   ibin_max        Maximum number of bins
            %   [ibin_buffer_max_size] -- the size of the buffer to read
            %                   pixels. Selected to allow multiple buffers
            %                   to be combined
            %
            % Output:
            % -------
            %   npix_section    npix_section(:,i) is the section npix(ibin_start:ibin_end) for the ith input file
            %   npix_in_bins    cumsum of the number of pixels
            %   ibin_end        Last bin number in the buffer - it is determined either by the maximum size of nbin in the
            %                  files (as given by ibin_max), or by the largest permitted size of the buffer
            %   Throws SQW_BINFILE_IO:runtime_error with brief problem description
            %                  in case of problem with read operations.
            [npix_section,ibin_end]=get_npix_section_(obj,ibin_start,ibin_max,varargin{:});
            npix_in_bins = cumsum(sum(npix_section,2));
        end
        %
        function [pix_buffer,pos_pixstart] = read_pixels(obj,n_file,pos_pixstart,npix2read)
            % read pixel block of the appropriate size and move read
            % pointer to the next position
            %Inputs:
            % fid          -- the file identified of an opened file
            % pos_pixstart -- the initial position of the pix block to read
            % npix2read    -- number of pixels to read
            %
            fid = obj.fid_(n_file);
            
            fseek(fid,pos_pixstart,'bof');
            [pix_buffer,count_out] = fread(fid,[9,npix2read],'*float32');
            if count_out ~=9*npix2read
                error('SQW_FILE_IO:runtime_error',...
                    ' Number of pixels read %d is smaller then the number requested: %d',...
                    count_out/9,npix2read);
            end
            [f_message,f_errnum] = ferror(fid);
            if f_errnum ~=0
                error('SQW_FILE_IO:runtime_error',...
                    'Error N%d during IO operation: %s',f_errnum,f_message);
            end
            pos_pixstart = ftell(fid); %set up next read position
        end
        %
        function n_pix_written=write_pixels(obj,pix_section,n_pix_written)
            % Write properly formed pixels block to the output file
            
            fout = obj.fout_;
            fwrite(fout, single(pix_section), 'float32');    % write to output file
            n_pix_written = n_pix_written+size(pix_section,2);
        end
        
    end
    
    methods(Static)
        %
        function [npix_2_read,npix_processed,npix_per_bins_left,npix_in_bins_left,last_fit_bin] = ...
                nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size)
            % calculate number of bins to read enough pixels to fill pixels
            % buffer and recalculate the number of pixels to read from every
            % contributing file.
            % Inputs:
            % npix_per_bins  -- 2D array containing the section of numbers of
            %                   pixels per bin per file
            % npix_in_bins   -- cumulative sum of pixels in bins of all files
            % npix_processed -- first bin to analyze from the npix_section
            %                   and npix_in_bins
            % pix_buf_size   -- the size of pixels buffer intended for
            %                   writing
            % Outputs:
            % npix_2_read  --  2D array, containing the number of pixels
            %                  in bins to read per file.
            % npix_processed --total number of pixels to process during
            %                  flowing read operation. Usually equal to
            %                  pix_buf_size if there are enough pixels
            %                  left.
            % npix_per_bins_left -- reduced 2D array containing the section of
            %                   numbers of pixels per bin per file left to
            %                   process in following IO operations.
            % npix_in_bins_left  --  reduced cumulative sum of pixels in bins
            %                   of all files left to process in following
            %                   IO operations.
            % last_fit_bin  -- the last bin number to process for  the pixels
            %                  to fit pix buffer
            
            %
            % See: test_sqw/test_nsqw2sqw_internal_methods for the details
            % of the method functionality
            %
            [npix_2_read,npix_processed,npix_per_bins_left,npix_in_bins_left,last_fit_bin] = ...
                nbin_for_pixels_(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size);
        end
        %
        
        %
        function [common_par,loop_par ] = pack_job_pars(pix_comb_info,...
                fout_name,pix_out_pos,n_workers,combine_mode)
            % prepare job parameter in the form, suitable for splitting them between jobs and sending them
            % to parallel workers.
            %
            % Inputs:
            % pix_comb_info -- the structure, containing the information
            %                  about pixel amd nbin blocks locations
            %                  within all input files
            % fout_name     -- full name (with path) of ouptup sqw file
            % pix_out_pos   -- the location of the pixel block within
            %                  binary output sqw file
            % n_workers     -- number of parallel workers to do the job
            % combine_mode  -- 1 or 2 depending on the parallel combine job
            %                  separation, namely 1 -- 1 writer multiple
            %                  readers job or 2 -- 1 writer, 1 combiner and
            %                  other threads -- data readers.
            if n_workers < 2
                error('COMBINE_SQW_PIX_JOB:invalid_argument',...
                    'this parallel job needs at least 2 MPI workers, while provided with %d',...
                    n_workers);
            end
            if ~exist('combine_mode','var')
                combine_mode = 1;
            end
            writer_job_par = struct();
            writer_job_par.fout_name   = fout_name;
            writer_job_par.pix_out_pos = pix_out_pos;
            
            common_par = struct();
            common_par.nbin     = pix_comb_info.nbins;
            common_par.npixels  = pix_comb_info.num_pixels;
            if n_workers<3 && combine_mode>1
                warning('COMBINE_SQW_PIX_JOB:invalid_argument',...
                    ' combine mode 2 can be enabled for more then 3 workers only. Switching to combine mode 1')
                combine_mode = 1;
            end
            common_par.combine_mode = combine_mode;
            
            whole_buffer = config_store.instance().get_value('hor_config','mem_chunk_size');
            if combine_mode == 1
                n_readers = n_workers-1;
            else
                n_readers = n_workers-2;
            end
            
            % the reader buffers together should be equal to the write buffer
            common_par.pix_buf_size = ceil(whole_buffer/(n_readers));
            % less workers as one worker will hold the write job
            loop_par = pix_comb_info.split_into_parts(n_readers);
            % add special loop par for the first worker as the first worker
            % will write rather than read
            if combine_mode == 1
                loop_par = [{writer_job_par},loop_par];
            else
                % also add empty loop par for combine job worker
                loop_par = [{writer_job_par},{''},loop_par];
            end
        end
    end
end


