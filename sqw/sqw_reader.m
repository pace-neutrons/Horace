classdef sqw_reader<handle
    % Class provides bin and pixel information for a pixes of an sqw file.
    %
    % Created to read bin and pixel information from a cell stored on hdd,
    % but optimized for subsequent data access, so subsequent cells are
    % cashied in a buffer and provided from the buffer if availible
    %
    %
    % $Revision: 1099 $ ($Date: 2015-12-07 21:20:34 +0000 (Mon, 07 Dec 2015) $)
    %
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
        % the info distinguishing
        file_id_ = [];
        % -----------------------------------------------------------
        % buffer containing bin info
        nbin_buffer_=[];
        nbin_sum_buffer_=[];
        num_first_bin_;  % number of first bin in the buffer
        num_buf_bins_; %  size of nbin_buffer_
        
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
            % sqw reader constructor requests
            %
            % fname          -- name of the file to read data from or id
            %                   for open file
            % npix_start_pos -- starting position of bin info in the file
            % n_bins         -- total number of bins in a file
            % pix_start_pos  -- starting postion of pixel info in the file
            % file_id        -- number, which distinguish pixels of this
            %                   file from others (or empty if no
            %                   modifications for pixels id is necessary)
            %
            if isinteger(fname)
                file = fopen(fname);
                if isemtpy(file)
                end
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
            self.num_first_buf_pix_= 1; % number of first pix currently in the buffer
            self.num_buf_pix_      = 0; % number of pix info in the buffer
            % make pix_buf size proportional to optimal data read unit
            % (real size will be 9 times bigger, as a pixel has 9 fields)
            self.pix_buf_size_   =  sqw_reader.bin_buf_size_;
            
        end
        %
        function npix     = get_npix_for_bin(self,bin_number)
            % get number of pixels, stored in the bin
            % with the bin number provided
            %
            % bin_number -- number of pixel to get information for
            % Returns:
            % number of pixels, stored in this bin
            %
            if bin_number > self.num_bins_ || bin_number<1
                error('SQW_READER:read_pix','The file %s does not have bin N %d',self.full_file_name_,bin_number);
            end
            
            n_loc_bin  = bin_number - self.nbin_start_pos_+1;
            if n_loc_bin > self.num_buf_bins_
                self.read_bin_info_(bin_number);
                n_loc_bin  = bin_number - self.nbin_start_pos_+1;
            elseif n_loc_bin<1 % cashe miss
                self.nbin_start_pos_ = bin_number;
                self.num_buf_bins_   = 0;
                self.read_bin_info_(bin_number);
                n_loc_bin   = bin_number;
            end
            npix = self.nbin_buffer_(n_loc_bin);
            %
            % Clear pixel buffer if bin buffer points outside of pixel
            % buffer
            n_pix_bin = bin_number - self.num_first_bin_;
            if n_pix_bin > self.num_buf_pix_
                self.num_buf_pix_ = 0;
                self.pix_buffer_ = [];
                self.num_first_bin_ = bin_number;
            end
            
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
            if bin_number > self.num_bins_ || bin_number<1
                error('SQW_READER:read_pix','The file %s does not have bin N %d',self.full_file_name_,bin_number);
            end
            pix_buf_number = bin_number-self.num_first_buf_pix_+1;
            if pix_buf_number > self.num_buf_pix_
                % read pixel information in the buffer
                self.read_pixels_(bin_number)
                pix_buf_number = bin_number-self.num_first_buf_pix_+1;
            elseif pix_buf_number<1 % cash miss,
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
            % pixels and return enough pixels to fill-in buffer. Expand or
            % shrink if nexessary
            num_pix_to_read = self.check_binInfo_loaded_(first_bin_number);
            %
            
            pix_pos =  self.pix_start_pos_ + (bin_number-1)*self.pix_bloc_size_;
            fseek(self.fid_,pix_pos,'bof');
            [pix_buffer,count,ok,mess] = fread_catch(self.fid_,[9,num_pix_to_read],'*float32');
            if ~all(ok);
                error('SQW_READER:read_pix','Error %s while reading file %s',mess,self.full_file_name_);
            end
            self.num_first_buf_pix_ = bin_number;
            self.num_buf_pix_       = num_pix_to_read;
            if num_pix_to_read > 0 && ~isempty(self.file_id_)
                pix_buffer(5,:) = self.self.file_id_;
            end
            self.pix_buffer_ = pix_buffer;
            
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
        function read_bin_info_(self,nbin2read,varargin)
            % Method to read block of information about number of pixels
            % stored according to bins starting with the bin number spefied
            % as input
            %
            % nbin2read -- the first bin to read into the buffer
            
            % number of bins to read into buffer:
            if nbin2read > self.num_bins_
                error('SQW_READER:read_pix','trying to read bin infor for the bin N %d located outside of the bin range',nbin2read);
            end
            num_last_bin = nbin2read+self.bin_buf_size_;
            if num_last_bin > self.num_bins_
                num_last_bin = self.num_bins_;
            end
            tot_num_bins_to_read= num_last_bin-nbin2read;
            
            status=fseek(self.fid_,self.nbin_start_pos_+8*(nbin2read-1),'bof');
            if status<0
                error('SQW_READER:read_pix','Unable to find location of npix data in %s',self.full_file_name_);
            end
            [nbin_selection,count,ok,mess] = fread_catch(self.fid_,tot_num_bins_to_read,'*int64');
            if ~all(ok);
                error('SQW_READER:read_pix','error reading n_bin array: %s',mess);
            end;
            if nargin == 2 % read new bin buffer
                self.num_first_bin_  = nbin2read;
                self.nbin_buffer_    = nbin_selection;
                self.nbin_sum_buffer_= cumsum(nbin_selection);
                self.num_buf_bins_   = numel(nbin_selection);
            else  % expand existing bin buffer
                self.nbin_buffer_      = [self.nbin_buffer_(first_sum:end),nbin_selection];
                self.nbin_sum_buffer_  = cumsum(self.nbin_buffer_);
                self.num_buf_bins_     = numel(self.nbin_buffer_);
            end
        end
    end % methods
    
end

