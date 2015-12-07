classdef sqw_reader<handle
    % class supports chunk read operations from open sqw file
    % in order to combine these chunks into single sqw file.
    properties(Dependent)
        filename % short name of the file, this reader reads
        nbins    % number of bins, this file contains
    end
    properties(Access=private)
        fid_; % file id for open sqw file
        full_file_name_='';
        %
        nbin_start_pos_; % the initial file position where nbin array
        % (number of pixels in a bin) block
        num_bins_;      % the number of bins in this file
        %(the actual size of bin block is 8*num_bins_)
        pix_start_pos_; % the initial file position of pixel block
        %
        file_id_;
        % -----------------------------------------------------------
        % buffer containing bin info
        nbin_buffer_=[];
        nbin_sum_buffer_=[];
        num_first_bin_;  % number of first bin in the buffer
        num_buf_bins_; % (no more then nBinBuffer)
        
        % buffer containing pixels
        pix_buffer_=[];
        num_first_buf_pix_=1;
        num_buf_pix_ =0;
        pix_buf_size_ = 0;
    end
    properties (Constant,Access=private)
        % presumably ideal block-size to read
        bin_buf_size_=4096;
        pix_bloc_size_ = 9*4; % each pixel occupy this number of bytes
    end
    
    methods
        function self=sqw_reader(fname,npix_start_pos,n_bin,pix_start_pos,file_id)
            % npix_start_pos -- starting position of bin info in the file
            % n_bins         -- total number of bins in a file
            % pix_start_pos  -- starting postion of pixel info in file
            %
            self.full_file_name_ = fname;
            self.fid_ = fopen(fname,'r');
            if self.fid_ < 1
                error('SQW_READER:read_pix','Can not open file: %s',fname)
            end
            self.nbin_start_pos_ = npix_start_pos;
            self.num_bins_       = n_bin;
            self.pix_start_pos_  = pix_start_pos;
            self.file_id_        = file_id;
            
            self.num_first_bin_ = 1;  % number first bin currently in the buffer
            self.num_buf_bins_  = 0;  % number of bins in the buffer
            self.num_first_buf_pix_=1; % number of first pix currently in the buffer
            self.num_buf_pix_ =0;     % number of pix infor in the buffer
            % make pix_buf size proportional to optimal data read unit
            % (real size will be 9 times bigger, as a pixel has 9 fields)
            self.pix_buf_size_   =  sqw_reader.bin_buf_size_;
            
        end
        function pix_info = get_pix_for_bin(self,bin_number)
            % get pixels information for all pixels, located in the bin
            %
            % bin_number -- number of the bin to get info for
            %
            %
            if bin_number > self.num_bins_ || bin_number<1
                error('SQW_READER:read_pix','The file %s does not have bin N %d',self.full_file_name_,bin_number);
            end
            pix_buf_number = bin_number-self.num_first_buf_pix_+1;
            if pix_buf_number > self.num_buf_pix_
                % read pixel information in the buffer
                self.read_pixels_(bin_number)
                pix_buf_number = bin_number-self.num_first_buf_pix_+1;
            end
            % nbin buffer always contain information for more or equal to
            % the pix
            bin_buf_num = bin_number - self.num_first_bin_+1;
            npix = self.nbin_buffer_(bin_buf_num);
            if  npix >0
                pix_info = self.pix_buffer_(:,pix_buf_number:pix_buf_number+npix-1);
            else
                pix_info= [];
            end
        end
        
        function fn = get.filename(self)
            [~,name,fext] = fileparts(self.full_file_name_);
            fn = [name,fext];
        end
        function np = get.nbins(self)
            % Return number of bins this file contains and reader can read
            np = self.num_bins_;
        end
        %
        function  delete(self)
            %destructor
            fclose(self.fid_);
        end
    end
    
    methods(Access= private)
        function read_pixels_(self,bin_number)
            % read pixels information, located in the bin with the number requested
            %
            % read either all pixels in the buffer or at least the number
            % specified
            %
            first_bin_number = bin_number-self.num_first_bin_+1;
            % is bin information in memory?
            if first_bin_number > self.num_buf_bins_
                % read bin information in memory
                self.read_bin_info_(bin_number)
                first_bin_number = first_bin_number -self.num_first_bin_+1;
            end
            % check if we have loaded enough bin information to read enough
            % pixels and return enough pixels to fill-in buffer
            num_pix_to_read = self.check_binInfo_loaded_(first_bin_number);
            %
            
            pix_pos =  self.pix_start_pos_ + (bin_number-1)*self.pix_bloc_size_;
            fseek(self.fid_,pix_pos,'bof');
            [self.pix_buffer_,count,ok,mess] = fread_catch(self.fid_,[9,num_pix_to_read],'*float32');
            if ~all(ok);
                error('SQW_READER:read_pix','Error %s while reading file %s',mess,self.full_file_name_);
            end
            self.num_first_buf_pix_ = bin_number;
            self.num_buf_pix_       = num_pix_to_read;
            
        end
        function num_pix_to_read=check_binInfo_loaded_(self,first_bin_number)
            % verify bin information loaded to memory and identify sufficient number
            % of pixels to fill-in pixels buffer.
            %
            % read additional bin information if not enough bins have been
            % processed or
            %
            last_bin_number = first_bin_number + self.num_buf_bins_-1;
            if (first_bin_number <=1)
                prev_npix = 0;
            else
                prev_npix = self.nbin_sum_buffer_(first_bin_number);
            end
            num_pix_to_read = self.nbin_sum_buffer_(last_bin_number)-prev_npix;
            if num_pix_to_read > self.pix_buf_size_
                last_bin_number = find(self.nbin_sum_buffer_ <= self.pix_buf_size_+prev_npix,1,'last');
            else
                while(num_pix_to_read < self.pix_buf_size_ && last_bin_number<self.num_bins_)
                    self.read_bin_info_(last_bin_number,'expand')
                    last_bin_number = first_bin_number + self.num_buf_bins_-1;
                    num_pix_to_read = self.nbin_sum_buffer_(last_bin_number)-prev_npix;
                end
                if num_pix_to_read > self.pix_buf_size_
                    last_bin_number = find(self.nbin_sum_buffer_ <= self.pix_buf_size_+prev_npix,1,'last');
                end
            end
            num_pix_to_read = self.nbin_sum_buffer_(last_bin_number)-prev_npix;
        end
        function read_bin_info_(self,num_bin2read,varargin)
            % Method to read block of information about number of pixels
            % stored according to bins starting with the bin number spefied
            % as input
            %
            % num_bin2read
            
            % number of bins to read into buffer:
            if num_bin2read > self.num_bins_
                error('SQW_READER:read_pix','trying to read bin infor for the bin N %d located outside of bin range',num_bin2read);
            end
            num_last_bin = num_bin2read+self.bin_buf_size_;
            if num_last_bin > self.num_bins_
                num_last_bin = self.num_bins_;
            end
            tot_num_bins_to_read= num_last_bin-num_bin2read;
            
            status=fseek(self.fid_,self.nbin_start_pos_+8*(num_bin2read-1),'bof');
            if status<0
                error('SQW_READER:read_pix','Unable to find location of npix data in %s',self.full_file_name_);
            end
            [nbin_selection,count,ok,mess] = fread_catch(self.fid_,tot_num_bins_to_read,'*int64');
            if ~all(ok);
                error('SQW_READER:read_pix','error reading n_bin array: %s',mess);
            end;
            if nargin == 2 % read new bin buffer
                self.num_first_bin_ = num_bin2read;
                self.nbin_buffer_   = nbin_selection;
                self.nbin_sum_buffer_ = cumsum(nbin_selection);
                self.num_buf_bins_  = numel(nbin_selection);
            else  % expand existing bin buffer
                self.nbin_buffer_ = [self.nbin_buffer_,nbin_selection];
                prev_sum = self.nbin_sum_buffer_(end);
                self.nbin_sum_buffer_  = [self.nbin_sum_buffer_,cumsum(nbin_selection)+prev_sum];
                self.num_buf_bins_  = self.num_buf_bins_  + numel(nbin_selection);
            end
        end
    end % methods
    
end

