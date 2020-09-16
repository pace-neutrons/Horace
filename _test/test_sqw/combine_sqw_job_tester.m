classdef combine_sqw_job_tester < combine_sqw_pix_job
    % the class helper for combine_sqw_pix_job class, providing fake
    % read_pix method
    properties(Dependent)
        pix_combine_info;
        fid
    end
    methods
        function obj = init_fake_mpi(obj,n_files,buf_size,n_pixels,n_bins)
            if nargin>2
                common_par  = struct('nbin',n_bins,'npixels',n_pixels);
                obj.common_data_ = common_par;
            end
            obj.mess_framework_ = fake_mess_provider(n_pixels,n_bins,...
                n_files,buf_size);
        end
        %
        function [obj,mess]=init(obj,fbMPI,intercom_class,InitMessage,is_tested)
            [obj,mess] = init@combine_sqw_pix_job(obj,fbMPI,intercom_class,InitMessage,is_tested);
            
            n_files = 10;
            buf_size = 100;
            obj = obj.init_fake_mpi(n_files,buf_size);
        end
        %
        function px = get.pix_combine_info(obj)
            px = obj.pix_combine_info_;
        end
        function obj = set.pix_combine_info(obj,val)
            obj.pix_combine_info_ = val;
        end
        function fid = get.fid(obj)
            fid = obj.fid_;
        end
        function obj = set.fid(obj,val)
            obj.fid_ = val;
        end
        %
        function [pix_buffer,pos_pixstart] = read_pixels(obj,n_file,pos_pixstart,npix2read)
            mf = obj.mess_framework_;
            file_data = mf.file_blocks{n_file};
            pix_buffer = file_data(:,pos_pixstart:(pos_pixstart+npix2read-1));
            pos_pixstart = pos_pixstart+npix2read;
        end
        %
        function n_pix_written=write_pixels(obj,pix_section,n_pix_written)
            % Write properly formed pixels block to the output file
            mf = obj.mess_framework_;
            pix_block = mf.combined_pix_data;
            mf.combined_pix_data = [pix_block,pix_section];
            n_pix_written = n_pix_written+size(pix_section,2);
        end
        %
        function npix_section = read_npix_block(obj,ibin_start,nbin_buf_size)
            % Inputs:
            % ibin_start -- first bin to process
            % nbin_buf_size -- number of bins to read and process
            %
            % Uses pix_combine info, containing locations of the npix blocks in all
            % input files and defined as property of the cobine_pix job
            %
            % Returns:
            % 2D array of size [nbin x n_files] with every column
            % containing npix info i.e. the numbers of pixels per bin in
            % the bin ragne specified as input
            
            mf = obj.mess_framework_;
            fid_ = obj.fid_;
            % that's where one should expect npix data block is physicall
            % located.
            pos_npixstart = obj.pix_combine_info_.pos_npixstart;
            
            nfiles = numel(fid_);
            npix_section = int64(zeros(nbin_buf_size,nfiles));
            bins = 1:mf.n_bins;
            bin_sec = bins(ibin_start:(ibin_start-1+nbin_buf_size));
            for i=1:nfiles
                fd = mf.file_blocks{i};
                % what bins are filled in our pseudofile
                bins_selected = ismember(fd(1,:),bin_sec);
                bins_block = fd(1,bins_selected );
                npix_block = arrayfun(@(nb)(numel(find(bins_block == nb))),...
                    bin_sec);
                npix_section(:,i) = npix_block;
            end
        end
    end
    
    methods(Static)
    end
end
