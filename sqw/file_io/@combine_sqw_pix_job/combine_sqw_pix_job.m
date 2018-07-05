classdef combine_sqw_pix_job < JobExecutor
    % combine pixels located in multiple sqw files into continuous pixels block
    % located in a single sqw file
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
        function [pix_section,pos_pixstart]=...
                read_pix_for_nbins_block(obj,fid,pos_pixstart,npix_per_bin,...
                run_label,change_fileno,relabel_with_fnum)
            % take range of open input files and
            % read pixels blocks corresponding to the input bins block
            % provided.
            % Inputs:
            % fid -- array of open file identifiers.
            % pos_pixstart -- binary positions of the start of the pixels
            %                 block
            % npix_per_bin -- number of pixels within selected bin block
            % run_label    -- array of numbers which distinguish one input
            %                 file from another
            % change_fileno-- boolean specifies if pixel info should be
            %                 relabeled according to runlabel or filenum
            % relabel_with_fnum -- boolean specifies if pixel info should
            %                 be relabeled by runlabel or filenum depending
            %                 on this switch.
            %
            npix_per_file = sum(npix_per_bin,2);
            n_bin2_process= size(npix_per_bin,2);
            nfiles        = size(npix_per_bin,1);
            
            % Read pixels from input files
            pix_tb=cell(nfiles,n_bin2_process);  % buffer for pixel information
            npixels = 0;
            %
            bin_filled = false(n_bin2_process,1);
            for i=1:nfiles
                if npix_per_file(i)>0
                    [pix_buf,pos_pixstart(i)] = ...
                        obj.read_pixels(fid(i),pos_pixstart(i),npix_per_file(i));
                    [bin_cell,nonempty_bin] = split_pix_per_bin_(pix_buf,npix_per_bin(i,:),...
                        i,run_label(i),change_fileno,relabel_with_fnum);
                    pix_tb(i,nonempty_bin) = bin_cell(:);
                    npixels = npixels +numel(pix_tb{i});
                    bin_filled(nonempty_bin) = true;
                end
            end
            %
            % combine pix from all files according to the bin
            pix_tb = pix_tb(:,bin_filled); % accelerate combiniong by removing empty cells
            pix_section = cat(2,pix_tb{:});
            
            
        end
        function n_pix_written=write_pixels(obj,fout,pix_section,n_pix_written)
            % Write to the output file
            
            %pix_buff = [pix_section{:}];
            %pix_buff  = reshape(pix_buff,numel(pix_buff),1);
            

            fwrite(fout,pix_section,'float32');    % write to output file
            n_pix_written = n_pix_written+size(pix_section,2);            
        end
        
        function obj=do_job(obj)
        end
        function obj=reduce_data(obj)
            obj.is_finished_  = true;
        end
        function ok = is_completed(obj)
            ok = obj.is_finished_;
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
            % buffer and recalculate the number of pixes to read from every
            % contributing file.
            % Inputs:
            % npix_per_bins -- 2D array containing the section of numbers of
            %                  pixels per bin per file
            % npix_in_bins  -- cumulative sum of pixels in bins of all files
            % bin_start     -- first bin to analyze from the npix_section
            %                 and npix_in_bins
            % pix_buf_size -- the size of pixels buffer intended for
            %                 writing
            % Outputs:
            % npix_2_read  --  2D array, containing the number of pixels
            %                  in bins to read per file.
            % npix_processed --total number of pixels to process during
            %                  folowing read operation. Usually equal to
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
            pos_pixstart = ftell(fid); %pos_pixstart+npix2read;
        end
        %
    end
end

