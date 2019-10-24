classdef sqw_reader<handle
    % Class provides bin and pixel information for a pixels of an sqw file.
    %
    % Created to read bin and pixel information from a cell stored on hdd,
    % but optimized for subsequent data access, so subsequent cells are
    % cached in a buffer and provided from the buffer if available
    %
    %
    % $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
    %
    properties(Dependent)
        filename % short name of the file, this reader reads
        nbins    % number of bins, this file contains
        % debugging 
        bin_buf_min
        bin_buf_max
        pix_buf_min
        pix_buf_max
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
        % the info distinguishing
        file_id_ = [];
        % -----------------------------------------------------------
        % buffer containing bin info
        nbin_buffer_=0;
        nbin_sum_buffer_=0;
        num_first_bin_=1;  % number of first bin in the buffer
        num_buf_bins_ =0; %  size of nbin_buffer_
        
        % buffer containing pixels
        pix_buffer_=[];
        pix_buf_size_ = 0;
        
        pix_in_buf_start_=1;
        pix_in_buf_end_ =0;
        
        
        num_processed_bins_=0;
        num_processed_pix_ =0;
    end
    properties (Constant,Access=private)
        % presumably ideal block-size to read
        buf_size_=4096;
        pix_bloc_size_ = 9*4; % each pixel occupy this number of bytes
        old_matlab_ = verLessThan('matlab','7.12');
    end
    
    methods
        function self=sqw_reader(fname,npix_start_pos,n_bin,pix_start_pos,file_id)
            % sqw reader constructor requests
            %
            % fname          -- name of the file to read data from or file
            %                   handle for open file
            % npix_start_pos -- starting position of bin info in the file
            % n_bins         -- total number of bins in a file
            % pix_start_pos  -- starting position of pixel info in the file
            % file_id        -- number, which distinguish pixels of this
            %                   file from others (or empty if no
            %                   modifications for pixels id is necessary)
            %
            if isinteger(fname)
                file = fopen(fname);
                if isemtpy(file)
                    error('SQW_READER:constructor','The handle N %d is not a file handle or file is closed',fname)
                end
                self.full_file_name_ = file;
                self.fid_ = fname;
            elseif ischar(fname)
                self.full_file_name_ = fname;
                self.fid_ = fopen(fname,'r');
                if self.fid_ < 1
                    error('SQW_READER:constructor','Can not open file: %s',fname)
                end
            else
                error('SQW_READER:constructor',' Input should be open file handle or the name of existing file')
            end
            
            self.nbin_start_pos_ = npix_start_pos;
            self.num_bins_       = n_bin;
            self.pix_start_pos_  = pix_start_pos;
            self.file_id_        = file_id;
            
            self.num_first_bin_    = 1; % number first bin currently in the buffer
            self.num_buf_bins_     = 0; % number of bins in the buffer
            self.pix_in_buf_start_= 1; % number of first pix currently in the buffer
            self.pix_in_buf_end_  = 0; % number of last pix in the buffer
            
            % make pix_buf size proportional to optimal data read unit
            % (real size will be 9 times bigger, as a pixel has 9 fields)
            self.pix_buf_size_   =  sqw_reader.buf_size_;
            
        end
        %
        % debugging functions
        function bm = get.bin_buf_min(self)
            bm  = self.num_first_bin_;
        end
        function bm = get.bin_buf_max(self)
            bm  = self.num_first_bin_+self.num_buf_bins_;            
        end
        function bm = get.pix_buf_min(self)
            bm =self.pix_in_buf_start_;
        end
        function bm = get.pix_buf_max(self)
            bm =self.pix_in_buf_end_;            
        end
        
        
        function [pix_num,npix] = get_npix_for_bin(self,bin_number)
            % get number of pixels, stored in the bin
            % with the bin number provided
            %
            % bin_number -- number of pixel to get information for
            % Returns:
            % number of pixels, stored in this bin
            %
            if bin_number > self.num_bins_ || bin_number<1
                error('SQW_READER:get_npix_for_bin','The file %s does not have bin N %d',self.full_file_name_,bin_number);
            end
            
            n_buf_bin  = bin_number - self.num_first_bin_+1;
            if n_buf_bin > self.num_buf_bins_
                self.read_all_bin_info(bin_number);
                n_buf_bin  = bin_number - self.num_first_bin_+1;
            elseif n_buf_bin<1 % cache miss
                self.num_buf_bins_   = 0;
                self.read_all_bin_info(bin_number);
                n_buf_bin  = bin_number - self.num_first_bin_+1;
            end
            npix     = self.nbin_buffer_(n_buf_bin);
            pix_num  = self.num_processed_pix_+self.nbin_sum_buffer_(n_buf_bin)+1;
            %
            
        end
        %
        function pix_info = get_pix_for_bin(self,bin_number)
            % get pixels information for all pixels, located in the bin
            %
            % bin_number -- number of the bin to get info for
            % Returns:
            % pixel info array size = [9,npix] containing pixel info
            % for the pixels, belonging to the bin requested
            %
            [pix_num,npix]   = get_npix_for_bin(self,bin_number);
            if npix == 0
                pix_info= [];
                return
            end
            if pix_num < self.pix_in_buf_start_ || pix_num>self.pix_in_buf_end_
                % read pixel information in the buffer
                self.read_pixels_(bin_number,pix_num)
            end
            pix_num_in_buf = pix_num-self.pix_in_buf_start_+1;
            if self.old_matlab_
                pix_num_in_buf  = double(pix_num_in_buf);
                npix = double(npix);
            end
            %
            pix_info = self.pix_buffer_(:,pix_num_in_buf:pix_num_in_buf+npix-1);
            
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
        function read_pixels_(self,bin_number,pix_number)
            % read pixels information, located in the bin with the number requested
            %
            % read either all pixels in the buffer or at least the number
            % specified
            %
            
            % check if we have loaded enough bin information to read enough
            % pixels and return enough pixels to fill-in buffer. Expand or
            % shrink if nexessary
            
            % if we are here, nbin buffer is intact and pixel buffer is
            % invalidated
            num_pix_to_read = self.check_binInfo_loaded_(bin_number);
            %
            
            pix_pos =  self.pix_start_pos_ + (pix_number-1)*self.pix_bloc_size_;
            fseek(self.fid_,pix_pos,'bof');
            [pix_buffer,count,ok,mess] = fread_catch(self.fid_,[9,num_pix_to_read],'*float32');
            if ~all(ok);
                error('SQW_READER:read_pix','Error %s while reading file %s',mess,self.full_file_name_);
            end
            self.pix_in_buf_start_ = pix_number;
            self.pix_in_buf_end_   = pix_number+num_pix_to_read-1;
            if num_pix_to_read > 0 && ~isempty(self.file_id_)
                pix_buffer(5,:) = self.file_id_;
            end
            self.pix_buffer_ = pix_buffer;
            
        end
        function num_pix_to_read=check_binInfo_loaded_(self,bin_number)
            % verify bin information loaded to memory and identify sufficient number
            % of pixels to fill-in pixels buffer.
            %
            % read additional bin information if not enough bins have been
            % processed
            %
            
            % pix info in bin buffer
            cache_bin_num = bin_number-self.num_first_bin_+1; % already guaranteed to be in bin buffer
            npix_start   = self.nbin_sum_buffer_(cache_bin_num)+1;
            npix_end     = self.nbin_sum_buffer_(end)+self.nbin_buffer_(end);
            num_pix_to_read = npix_end-npix_start+1;
            if num_pix_to_read > self.pix_buf_size_
                last_loc_pix_number = find(self.nbin_sum_buffer_ < self.buf_size_+npix_start-1,1,'last');
                if isempty(last_loc_pix_number)% so many pixels in a cell, that the first exceeds the buffer
                    num_pix_to_read = self.nbin_buffer_(cache_bin_num);
                else
                    num_pix_to_read = self.nbin_sum_buffer_(last_loc_pix_number)+self.nbin_buffer_(last_loc_pix_number)-npix_start+1;                    
                end

                % let's do nothing otherwise for the time being
                %else % npix buffer should be extended
                %    last_loc_pix_number = self.nbin_sum_buffer_(end-1);
                %    while(num_pix_to_read < self.pix_buf_size_+pix_buf_position && last_loc_pix_number<self.num_bins_)
                %        self.read_bin_info_(last_loc_pix_number,'expand')
                %        last_loc_pix_number = first_bin_number + self.num_buf_bins_-1;
                %        num_pix_to_read = self.nbin_sum_buffer_(last_loc_pix_number)-pix_buf_position;
                %    end
                %    if num_pix_to_read > self.pix_buf_size_
                %        last_loc_pix_number = find(self.nbin_sum_buffer_ <= self.buf_size_+pix_buf_position,1,'last');
                %    end
            end
            
        end
        function read_all_bin_info(self,nbin2read)
            %
            if nbin2read <self.num_processed_bins_ % cache missed, start reading again
                self.num_processed_bins_ = 0;
                self.num_processed_pix_  = 0;
                self.num_first_bin_      = 0;
                num_last_bin = 0;
            else
                self.num_processed_bins_ = self.num_processed_bins_+self.num_buf_bins_;
                self.num_processed_pix_  = self.num_processed_pix_+self.nbin_sum_buffer_(end)+self.nbin_buffer_(end);
                num_last_bin = self.num_processed_bins_;
            end
            n_strides = floor((nbin2read-num_last_bin)/self.buf_size_);
            
            for stride = 1:n_strides
                num_last_bin = read_bin_info_(self,1,'accumulate');
            end
            num_bin = nbin2read-num_last_bin;
            read_bin_info_(self,num_bin);
        end
        function num_last_bin = read_bin_info_(self,num_loc_bin,varargin)
            % Method to read block of information about number of pixels
            % stored according to bins starting with the bin number spefied
            % as input
            %
            % nbin2read -- the bin within a block to read into the buffer
            %
            
            % number of bins to read into buffer:
            
            first_bin =self.num_processed_bins_+1;                       
            num_last_bin = first_bin+self.buf_size_+num_loc_bin-2;
            
            if num_last_bin > self.num_bins_
                num_last_bin = self.num_bins_;
            end
            tot_num_bins_to_read= num_last_bin-first_bin+1;
            
            status=fseek(self.fid_,self.nbin_start_pos_+8*(first_bin-1),'bof');
            if status<0
                error('SQW_READER:read_pix','Unable to find location of npix data in %s',self.full_file_name_);
            end
            [nbin_selection,count,ok,mess] = fread_catch(self.fid_,tot_num_bins_to_read,'*int64');
            if ~all(ok);
                error('SQW_READER:read_pix','error reading n_bin array: %s',mess);
            end;
            if nargin == 2
                self.num_first_bin_  = first_bin;
                self.nbin_buffer_    = nbin_selection;
                if verLessThan('matlab','8.1')
                    nbin_selection = double(nbin_selection);
                end
                pix_pos = cumsum(nbin_selection);
                self.nbin_sum_buffer_= [0;pix_pos(1:end-1)];
                self.num_buf_bins_   = numel(nbin_selection);
            else
                self.num_processed_pix_  = self.num_processed_pix_+sum(nbin_selection);
                self.num_processed_bins_ = num_last_bin;
            end
        end
    end % methods
    
end

