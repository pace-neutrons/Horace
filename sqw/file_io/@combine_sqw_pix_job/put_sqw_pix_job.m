classdef combine_sqw_pix_job < JobExecutor
    % combine pixels located in multiple sqw files into continuous pixels block
    % located in a single sqw file
    
    properties(Access = private)
        is_finished_  = false;
    end
    
    methods
        function obj = combine_sqw_pix_job()
            obj = obj@JobExecutor();
        end
    end
    methods(Static)
        function [npix_section,ibin_end,mess]=get_npix_section(fid,pos_npixstart,ibin_start,ibin_max)
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
            %   ibin_end        Last bin number in the buffer - it is determined either by the maximum size of nbin in the
            %                  files (as given by ibin_max), or by the largest permitted size of the buffer
            %   mess            Error message: if all OK will be empty, if not OK will contain a message
            [npix_section,ibin_end,mess]=get_npix_section_(fid,pos_npixstart,ibin_start,ibin_max);
        end
        function [pix_section,ibin_end,mess]=read_pix_for_nbins_block(fid,npix_section,pos_pixstart,ibin_start,ibin_max)
            %
            % Calculate number of pixels to be read from all the files
            if (log_level>1)
                t_total_block = tic;
            end
            nbin_flush = ibin-ibin_lastflush;           % number of bins read into buffer
            npix_flush = zeros(nbin_flush,nfiles);      % to hold the no. pixels in each bin of the section we will write
            for i=1:nfiles
                npix_flush(:,i) = npix_section{i}(ibin_lastflush-ibin_start+2:ibin-ibin_start+1);
            end
            npix_in_files= sum(npix_flush,1);           % number of pixels to be read from each file
            % start and end pixel numbers for those bins with more than one pixel (for the others nend(i)=nbeg(i)-1)
            nend = reshape(cumsum(npix_flush(:)),size(npix_flush)); % end pixel number for each bin for each file
            nbeg = nend-npix_flush+1;                               % start pixel number for each bin for each file
            % Read pixels from input files
            pix_tb=cell(1,nfiles);                                  % buffer for pixel information
            npixels = 0;
            %
            if (log_level>1)
                tr = tic;
            end
            %
            for i=1:nfiles
                if npix_in_files(i)>0
                    try
                        [pix_tb{i},~,ok,mess] = fread_catch(fid(i),[9,npix_in_files(i)],'*float32');
                        npixels = npixels +numel(pix_tb{i});
                        %[pix_buff(:,nbeg(1,i):nend(end,i)),count,ok,mess] =
                    catch   % fixup to account for not reading required number of items (should really go in fread_catch)
                        ok = false;
                        error('SQW_FILE_IO:runtime_error',...
                            'Unrecoverable read error after maximum no. tries');
                    end
                    if ~all(ok)
                        error('SQW_FILE_IO:runtime_error',...
                            ['Error reading pixel data from ',infiles{i},' : ',mess]);
                    end
                end
            end
            %
            if (log_level>1)
                t_read=toc(tr);
                disp(['   ***time to read sub-cells: ',num2str(t_read),' speed: ',num2str(npixels*4/t_read/(1024*1024)),'MB/sec'])
            end
            
            
            if change_fileno
                for i=1:nfiles
                    pix_block = pix_tb{i};
                    if(numel(pix_block) > 0)
                        if relabel_with_fnum
                            pix_block(5,:)=i;
                        else
                            pix_block(5,:) =pix_block(5,:)+pix_comb_info.run_label(i); % offset the run index
                        end
                        pix_tb{i} = pix_block;
                    end
                end
            end
            pix_buff = cat(2,pix_tb{:});
            
        end
        
    end
end

