classdef combine_sqw_pix_job < JobExecutor
    % combine pixels located in multiple sqw files into continuous pixels block
    % located in a single sqw file
    %
    %
    %
    % $Revision: 780 $ ($Date: 2018-06-28 12:23:05 +0100 (Thu, 28 Jun 2018) $)
    %
    
    properties(Access = private)
        is_finished_  = false;
    end
    
    methods
        function obj = combine_sqw_pix_job()
            obj = obj@JobExecutor();
        end
        function obj=do_job(obj)
            
            mpis = MPI_State.instance();
            is_deployed = mpis.is_deployed;
            
            common_par      = obj.common_data_;
            pix_comb_info   = obj.loop_data_{1};
            
            pmax = config_store.instance().get_value('hor_config','mem_chunk_size');
            
            if job.labIndex <= 1
                filename = common_par.filename;
                fout = fopen(filename,'wb+');
                pix_out_position = common_par.pix_out_position;
                fseek(fout,pix_out_position,'bof');
                check_error_report_fail_(fout,...
                    ['Unable to move to the start of the pixel record in THE target file ',...
                    filename ,' starting matlab-combine']);
            else
                % Get number of files
                fid = verify_and_reopen_input_files_(pix_comb_info);
                % Always close opened files on the procedure completion
                clob = onCleanup(@()fcloser_(fid));  %
            end
            
            
            
            % Write the pixel information to the file
            %  The algorithm works as follows:
            %       - Outer loop: deals with each of the bins in the grid for the output file in turn
            %       - Inner loop: for each input file in turn, read the corresponding pixel information for that bin and then
            %                     write to the output file
            %  This is done because in general there is simply insufficient memory to hold the whole contents of all the files
            %
            %  We cannot read the number of pixels in each bin from all the individual input files, as we do not have enough
            %  memory even for that, in general. We need to read these in, a section at a time, into a buffer.
            % (For example, if 50^4 grid, 300 files then array size of npix= 8*300*50^4 = 15GB).
            
            
            % Unpack input structures
            relabel_with_fnum= pix_comb_info.relabel_with_fnum;
            change_fileno    = pix_comb_info.change_fileno;
            run_label        = pix_comb_info.run_label;
            filenum          = pix_comb_info.filenum;
            
            
            nbin = common_par.nbin;     % total number of bins
            npix = common_par.npixels;
            
            n_pix_written = 0;
            ibin_end = 0;
            
            pix_buf_size=pmax;
            pos_pixstart = pix_comb_info.pos_pixstart;
            mess_exch = obj.mess_framework;
            while ibin_end<nbin
                
                % Refill buffer with next section of npix arrays from the input files
                ibin_start = ibin_end+1;
                [npix_per_bins,npix_in_bins,ibin_end]=obj.get_npix_section(fid,pix_comb_info.pos_npixstart,ibin_start,nbin);
                npix_per_bins = npix_per_bins';
                
                % Get the largest bin index such that the pixel information can be put in buffer
                % (We hold data for many bins in a buffer, as there is an overhead from reading each bin from each file separately;
                % only read when the bin index fills as much of the buffer as possible, or if reaches the end of the array of buffered npix)
                n_pix_2process = npix_in_bins(end);
                npix_processed = 0;  % last pixel index for which data has been written to output file
                while npix_processed < n_pix_2process
                    if job.labIndex > 1
                        
                        [npix_per_bin2_read,npix_processed,npix_per_bins,npix_in_bins] = ...
                            obj.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size);
                        
                        [pix_section,pos_pixstart]=...
                            obj.read_pix_for_nbins_block(fid,pos_pixstart,npix_per_bin2_read,...
                            filenum,run_label,change_fileno,relabel_with_fnum);
                        
                        %
                        [ok,err_mess]=mess_exch.send_message(1,pix_section);
                        if ok ~= MESS_CODES.ok
                            error('COMBINE_SQW_PIX_JOB:runtime_error',err_mess);
                        end
                    else
                        messages = mess_exch.receive_all('all','data');
                        n_pix_written =obj.write_pixels(fout,pix_section,n_pix_written);
                        if is_deployed
                            mpis.do_logging(npix ,n_pix_written,[],[]);
                        end
                        
                    end
                    
                end
                
            end
            
            clear clob;
            if is_deployed
                mpis.do_logging(npix,npix);
            end
            
        end
        function obj=reduce_data(obj)
            obj.is_finished_  = true;
        end
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
        function n_pix_written=write_pixels(obj,fout,pix_section,n_pix_written)
            % Write properly formed pixels block to the output file
            
            %pix_buff = [pix_section{:}];
            %pix_buff  = reshape(pix_buff,numel(pix_buff),1);
            fwrite(fout,pix_section,'float32');    % write to output file
            n_pix_written = n_pix_written+size(pix_section,2);
        end
        
    end
    
    methods(Static)
        function [npix_section,npix_in_bins,ibin_end]=get_npix_section(fid,pos_npixstart,ibin_start,ibin_max)
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
            %
            % Output:
            % -------
            %   npix_section    npix_section{i} is the section npix(ibin_start:ibin_end) for the ith input file
            %   npix_in_bins    cumsum of the number of pixels
            %   ibin_end        Last bin number in the buffer - it is determined either by the maximum size of nbin in the
            %                  files (as given by ibin_max), or by the largest permitted size of the buffer
            %   Throws SQW_BINFILE_IO:runtime_error with brief problem description
            %                  in case of problem with read operations.
            [npix_section,ibin_end]=get_npix_section_(fid,pos_npixstart,ibin_start,ibin_max);
            npix_in_bins = cumsum(sum(npix_section,2));
        end
        %
        function [npix_2_read,npix_processed,npix_per_bins_left,npix_in_bins_left] = ...
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
            %
            % See: test_sqw/test_nsqw2sqw_internal_methods for the details
            % of the method functionality
            %
            [npix_2_read,npix_processed,npix_per_bins_left,npix_in_bins_left] = ...
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
            common_par = struct();
            common_par.nbin    = pix_comb_info.nbins;
            common_par.npixels = pix_comb_info.npixels;
            common_par.fout_name= fout_name;
            common_par.pix_out_pos = pix_out_pos;
            % less workers as one workes will hold the write job
            loop_par = pix_comb_info.split_into_parts(n_workers-1);
            % add empty loop par for the first worker as the first worker
            % will write rather than read
            loop_par = [{[]},loop_par];
        end
    end
end

