classdef combine_sqw_pix_job < JobExecutor
    % combine pixels located in multiple sqw files into continuous pixels block
    % located in a single sqw file
    %
    %
    %
    % $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
    %
    
    properties(Access = private)
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
    end
    
    methods
        function obj = combine_sqw_pix_job()
            obj = obj@JobExecutor();
        end
        function [obj,mess]=init(obj,fbMPI,job_control_struct,InitMessage)
            % Overloads parent's init by adding the initialization
            % routines, specific for combibe_sqw_pix_job
            %
            % All inputs are inhereted from parent init
            %
            % inputs and files:
            % fbMPI               -- the instance of file-based messages
            %                        framework, used to exchange messages
            %                        between worker and control node.
            %                        Depending on the used framework, this
            %                        class can be used as
            % job_control_struct  -- the structure,
            %                        containing information about
            %                        the messages framework to use
            % InitMessage         -- The message with information necessary
            %                        to run the job itself
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
            [obj,mess]=init@JobExecutor(obj,fbMPI,job_control_struct,InitMessage);
            if isempty(mess)
                if obj.labIndex == 1
                    obj.pix_cache_ = pix_cache(obj.mess_framework.numLabs);
                end
            end
            if obj.DEBUG
                fname = sprintf('comb_sqw_N%d_log.log',obj.labIndex);
                obj.h_log_file = fopen(fname,'w');
                obj.h_log_file_closer = onCleanup(@()fclose(obj.h_log_file));
            else
                obj.h_log_file = false;
            end
        end
        
        function obj=do_job(obj)
            % main executable code
            common_par      = obj.common_data_;
            pix_comb_info   = obj.loop_data_{1};
            
            if obj.DEBUG
                h_log_fl = obj.h_log_file;
            else
                h_log_fl = false;
            end
            
            if obj.labIndex == 1 % writer lab
                [fout,data_providers,data_remain,clob] = init_writer_job_(obj,pix_comb_info);
                
                receive_data_write_output_(obj,common_par,fout,data_providers,data_remain,h_log_fl);
                
            else  % reader labs
                % Get number of files
                fid = verify_and_reopen_input_files_(pix_comb_info);
                % Always close opened files on the procedure completion
                clob = onCleanup(@()fcloser_(fid));  %
                
                read_inputs_send_to_writer_(obj,common_par,pix_comb_info,fid,h_log_fl)
            end
            clear clob;
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
        % submethods necessary for main workflow
        %------------------------------------------------------------------
        function write_npix_to_pix_blocks(obj,fout,pix_out_position,pix_comb_info)
            % take pixels from the contributing files and place them into final sqw
            % file pixels block
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
        function [pix_section,pos_pixstart]=...
                read_pix_for_nbins_block(obj,fid,pos_pixstart,npix_per_bin,...
                filenum,run_label,change_fileno,relabel_with_fnum)
            % take range of open input files and
            % read pixels blocks corresponding to the input bins block
            % provided.
            % Inputs:
            % fid -- array of open file identifiers.
            % pos_pixstart -- binary positions of the start of the pixels
            %                 block to process
            % npix_per_bin -- 2D array of numbers of pixels per bin per file
            %                 within selected bin block
            % filenum      -- the array of filenumbers, used as pixel labels if
            %                 relabel_with_fnum is set to true; Replaces pixel ID in
            %                 this case.
            
            % run_label    -- array of numbers to distinguish one input
            %                 file from another. Added to current
            % change_fileno-- boolean specifies if pixel info should be
            %                 relabelled according to runlabel or filenum
            % relabel_with_fnum -- boolean specifies if pixel info should
            %                 be relabelled by runlabel or filenum depending
            %                 on this switch.
            %
            [pix_section,pos_pixstart]=...
                read_pix_for_nbins_block_(obj,fid,pos_pixstart,npix_per_bin,...
                filenum,run_label,change_fileno,relabel_with_fnum);
            
        end
        %
        function n_pix_written=write_pixels(obj,fout,pix_section,n_pix_written)
            % Write properly formed pixels block to the output file
            
            %pix_buff = [pix_section{:}];
            %pix_buff  = reshape(pix_buff,numel(pix_buff),1);
            fwrite(fout,pix_section,'float32');    % write to output file
            n_pix_written = n_pix_written+size(pix_section,2);
        end
        
    end
    
    methods(Static)
        function [npix_section,npix_in_bins,ibin_end]=get_npix_section(fid,pos_npixstart,ibin_start,ibin_max,varargin)
            % Fill a structure with sections of the npix arrays for all the input files. The positions of the
            % pointers in the input files is left at the positions on entry (the algorithm requires them to be moved, but returns
            % them at the end of the operation)
            %
            %   >> [npix_section,ibin_end,mess]=get_npix_section(fid,pos_npixstart,ibin_start,ibin_max)
            %
            % Input:
            % ------
            %   fid             Array of file identifiers for the input sqw files
            %   ibin_start      Get section starting with this bin number
            %   ibin_max        Maximum number of bins
            %   [ibin_buffer_max_size] -- the size of the buffer to read
            %                   pixels. Selected to allow multiple buffers
            %                   to be combined
            %
            % Output:
            % -------
            %   npix_section    npix_section{i} is the section npix(ibin_start:ibin_end) for the ith input file
            %   npix_in_bins    cumsum of the number of pixels
            %   ibin_end        Last bin number in the buffer - it is determined either by the maximum size of nbin in the
            %                  files (as given by ibin_max), or by the largest permitted size of the buffer
            %   Throws SQW_BINFILE_IO:runtime_error with brief problem description
            %                  in case of problem with read operations.
            [npix_section,ibin_end]=get_npix_section_(fid,pos_npixstart,ibin_start,ibin_max,varargin{:});
            npix_in_bins = cumsum(sum(npix_section,2));
        end
        %
        function [npix_2_read,npix_processed,npix_per_bins_left,npix_in_bins_left,last_fit_bin] = ...
                nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size)
            % calculate number of bins to read enough pixels to fill pixels
            % buffer and recalculate the number of pixels to read from every
            % contributing file.
            % Inputs:
            % npix_per_bins -- 2D array containing the section of numbers of
            %                  pixels per bin per file
            % npix_in_bins  -- cumulative sum of pixels in bins of all files
            % bin_start     -- first bin to analyse from the npix_section
            %                 and npix_in_bins
            % pix_buf_size -- the size of pixels buffer intended for
            %                 writing
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
        function [pix_buffer,pos_pixstart] = read_pixels(fid,pos_pixstart,npix2read)
            % read pixel block of the appropriate size and move read
            % pointer to the next position
            %Inputs:
            % fid          -- the file identified of an opened file
            % pos_pixstart -- the initial position of the pix block to read
            % npix2read    -- number of pixels to read
            %
            fseek(fid,pos_pixstart,'bof');
            [pix_buffer,count_out] = fread(fid,[9,npix2read],'*float32');
            if count_out ~=9*npix2read
                error('SQW_FILE_IO:runtime_error',...
                    ' Number of pixels read %d is smaller then the number requested: %d',...
                    count_ouf/9,npix2read);
            end
            [f_message,f_errnum] = ferror(fid);
            if f_errnum ~=0
                error('SQW_FILE_IO:runtime_error',...
                    'Error N%d during IO operation: %s',f_errnum,f_message);
            end
            pos_pixstart = ftell(fid); %set up next read position
        end
        %
        function [common_par,loop_par ] = pack_job_pars(pix_comb_info,fout_name,pix_out_pos,n_workers)
            % prepare job parameter in the form, suitable for
            if n_workers < 2
                error('COMBINE_SQW_PIX_JOB:invalid_argument',...
                    'this parallel job needs at least 2 MPI workers, while provided with %d',...
                    n_workers);
            end
            first_job_par = struct();
            first_job_par.fout_name   = fout_name;
            first_job_par.pix_out_pos = pix_out_pos;
            
            common_par = struct();
            common_par.nbin     = pix_comb_info.nbins;
            common_par.npixels  = pix_comb_info.npixels;
            
            whole_buffer = config_store.instance().get_value('hor_config','mem_chunk_size');
            % the reader buffers together should be equal to the write buffer
            common_par.pix_buf_size = ceil(whole_buffer/(n_workers-1));
            % less workers as one workes will hold the write job
            loop_par = pix_comb_info.split_into_parts(n_workers-1);
            % add empty loop par for the first worker as the first worker
            % will write rather than read
            loop_par = [{first_job_par},loop_par];
        end
    end
end

