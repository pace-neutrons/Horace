classdef pix_cache
    % Implements cache for the pixels, transmitted through MPI messages
    % for combine_sqw_pix_job.
    %
    % Each read job sends read pixels independently, when write job
    % should receive and combine pixels, corresponding to the range of full
    % bins to write.
    %
    % As messages from jobs contain pixels for different number of bins the
    % cache is implemented to keep for the future combining the pixels
    % for the bins which have not yet received all pixels.
    %
    % The payload of a data message containing pix information for cache
    % contains the the following fields:
    %
    % npix      -- number of pixels, attached to the message.
    % n_source  -- the ID(number) of the contributing reader, who sends this
    %              particular message
    % bin_range -- 2 elements array, containing min-max number of bins,
    %              these pixels contribute to
    % last_bin_completed (true, false)
    %           -- boolean, indicating that all pixels of the last
    %              bin are provided in last pix_tb cell or some of them
    %              have not fit the buffer and will be send in the
    %              following message
    % pix_tb    -- cellarray with each cell containing pixels, contributed
    %              to a bin.
    % filled_bin_ind -- the indexes of the bins, the pixels from pix_tb
    %              contribute to. I.e. if message contains
    %              pixels from bins 10-20, where bins 12 and 15 are empty,
    %              the message will contain
    %              pix_tb == cell(9,8) (with pix blocks),  bin_range==[10,20]
    %              and  filled_bin_ind==[1,2,4,5,7,8,9,10]
    %
    properties(Dependent)
        % number of parallel readers providing the data.
        n_readers
        %
        first_bin_to_process;
        last_bin_processed
        %
        all_bin_range
    end
    
    properties(Access=protected)
        % number of parallel readers, providing data for combining
        n_readers_
        
        % the array of containing the min and max bin numbers,
        % for the pixels, present in cache. size or the array is == [2,n_readers]
        % where the n_readers== n_workers -1 or n_workers -2 is the
        % number of workers, used to read data from the partial files.
        bin_range_   = [];
        
        % a n_readers (n_workers-1[2]) cellarray, with each cell containing
        % pixels contributing to each non-empty bin currently in the cache
        read_pix_cache_       = {};
        
        % the indexes of the bins, caching non-empty pixel data
        % (in read_pix_cache_ above)
        filled_bin_ind_ ={};
        
        % the number of the first bin to process when pop_pixels command is
        % invoked.
        first_bin_to_process_ = 1;
        
        % the boolean of n_readers size, containing true, if all pixels
        % of the last bin are stored in the cache or true if they are not
        last_bin_completed_ = [];
    end
    
    methods
        function obj = pix_cache(n_readers)
            obj.n_readers_      = n_readers;
            obj.bin_range_      =  zeros(2,n_readers);
            obj.filled_bin_ind_ =  cell(n_readers,1);
            obj.read_pix_cache_ =  cell(n_readers,1);
            obj.last_bin_completed_ =true(n_readers,1);
        end
        function dr = data_remain(obj,n_bins)
            dr = obj.bin_range_(2,:)<n_bins;
        end
        function lbp=get.last_bin_processed(obj)
            lbp = obj.first_bin_to_process_ -1;
        end
        function ran = get.all_bin_range(obj)
            ran = obj.bin_range_ ;
        end
        function nbin = get.first_bin_to_process(obj)
            nbin = obj.first_bin_to_process_;
        end
        function obj = set.first_bin_to_process(obj,nbin)
            if ~isnumeric(nbin)
                error('PIX_CACHE:invalid_argument',...
                    'first bin to process has to be numeric')
            end
            if nbin<1
                error('PIX_CACHE:invalid_argument',...
                    'first bin to process has to be > 1; got %d',nbin);
            end
            obj.first_bin_to_process_= nbin;
        end
        
        function nwk = get.n_readers(obj)
            nwk = obj.n_readers_;
        end
        %
        function[obj,npix_received] = push_messages(obj,mess_list,h_log)
            % retrieve pixel and bin information from messages and store
            % this information in message cache, together with information
            % from the previous messages
            %
            % Returns:
            % obj           - with filled bin and pixels cache
            % npix_received - number of pixels, containing in the messages
            %
            if ~exist('h_log','var')
                h_log = false;
            end
            
            n_mess = numel(mess_list); % A message contains pixels from a files,
            % combined on a worker, so may be considered as a "file"
            npix_received = 0;
            npix_stored = 0;
            for i=1:n_mess
                % some messages may not be send any more.
                if isempty(mess_list{i})
                    continue;
                end
                pl = mess_list{i}.payload;
                n_source = pl.n_source;
                if h_log
                    fprintf(h_log,...
                        '********************  Message %d with range [%d , %d], filled in %d bins; has %d pixels\n;',...
                        i,pl.bin_range,numel(pl.filled_bin_ind),pl.npix);
                    if pl.bin_range(1)>obj.bin_range_(2,i)+1 % missed short message?
                        fprintf(h_log,...
                            '******************** MessN %d, mes Range %d obj range %d\n',...
                            pl.messN,pl.bin_range(1),obj.bin_range_(2,i));
                        %data = labReceive(pl.messN,mess_list{i}.tag);
                    end
                    
                end
                if pl.npix == 0
                    obj.bin_range_(1,n_source)    =   obj.first_bin_to_process;
                    obj.bin_range_(2,n_source)    =   pl.bin_range(2);
                else
                    if isempty(obj.read_pix_cache_{n_source})
                        obj.filled_bin_ind_{n_source}   = pl.filled_bin_ind;
                        obj.read_pix_cache_{n_source}   = pl.pix_tb;
                        obj.bin_range_(:,n_source)      = pl.bin_range;
                    else
                        range_existing_bins = obj.bin_range_(2,n_source )-obj.bin_range_(1,n_source )+1;
                        if h_log
                            npix_stored = npix_stored + sum(cellfun(@(x)numel(x),obj.read_pix_cache_{n_source }));
                        end
                        % combine pixel caches and bin ranges of all
                        % messages
                        pix_cache_exist = obj.filled_bin_ind_{n_source};
                        bin_ind_exist = obj.filled_bin_ind_{n_source };
                        if obj.last_bin_completed_(n_source)
                            bin_ind_add = pl.filled_bin_ind+range_existing_bins;
                            pix_cache_add =  pl.pix_tb;
                        else
                            % bins of the last message
                            if numel(pl.filled_bin_ind)>1
                                bin_ind_add = pl.filled_bin_ind(2:end)+range_existing_bins;
                            else
                                bin_ind_add =[];
                            end
                            % combine last existing pix cell and first cell
                            % of the new message.
                            pix_cache_exist{end} = [pix_cache_exist{end},pl.pix_tb{1}];
                            pix_cache_add =  pl.pix_tb{2:end};
                        end
                        
                        obj.filled_bin_ind_{n_source } = [bin_ind_exist,bin_ind_add];
                        obj.read_pix_cache_{n_source } = [pix_cache_exist,pix_cache_add];
                        obj.bin_range_(2,n_source)     = pl.bin_range(2);
                    end
                    obj.last_bin_completed_(n_source) = pl.last_bin_completed;
                end
                npix_received = npix_received+pl.npix;
            end
            
            % debug and verification
            if h_log
                fprintf(h_log,...
                    '********************  Npix in cache: %d, npix received %d, total %d\n',...
                    npix_stored,npix_received,npix_received+npix_stored);
                if any(obj.bin_range_(1,:) ~=obj.bin_range_(1,1))
                    error('PIX_CASH:runtime_error',...
                        'some lower bin ranges are not equal' )
                end
            end
            
        end
        %
        function [obj,pix_section] = pop_pixels(obj,h_log)
            % return the pixels block containing pixels for the bins
            % which have full information about pixels.
            %
            % clear cache from this information and keep only the
            % pixels for bin without full pixel information.
            
            if ~exist('h_log','var')
                h_log = false;
            end
            n_files = size(obj.bin_range_,2);
            first_bin_to_proc = obj.bin_range_(1,1); % they must be all equal;
            last_bin_to_process = min(obj.bin_range_(2,:));
            
            % number of bins in cache, containing full pixels information
            n_bins = last_bin_to_process  - first_bin_to_proc +1;
            
            
            % expanded index of the bins, containing any pixels
            %
            % assume that no bins are currently filled
            bin_has_pixels = false(n_bins,1);
            bin_indexes= 1:n_bins;
            
            pix_tb = cell(n_files,n_bins);
            npix_left = 0;
            for i=1:n_files
                bic = obj.filled_bin_ind_{i};
                if isempty(bic)
                    continue;
                end
                bin_filled = ismember(bin_indexes,bic);
                pic = obj.read_pix_cache_{i};
                %
                bins_selected = ismember(bic,bin_indexes);
                
                pix_tb(i,bin_filled ) = pic(bins_selected);
                if ~all(bins_selected)%obj.bin_range_(2,i) > last_bin_to_process % store remaining bin and pixel info for future analysis
                    % last processed bin number
                    
                    obj.filled_bin_ind_{i} = bic(~bins_selected)-n_bins;
                    obj.read_pix_cache_{i} = pic(~bins_selected);
                    if h_log
                        npix_left = npix_left + sum(cellfun(@(x)numel(x),obj.read_pix_cache_{i}));
                    end
                else
                    obj.filled_bin_ind_{i} = [];
                    obj.read_pix_cache_{i}  = {};
                end
                obj.bin_range_(1,i)    = last_bin_to_process+1;
                
                bin_has_pixels(bin_filled) = true;
            end
            
            pix_tb = pix_tb(:,bin_has_pixels); % accelerate combining by removing empty cells
            % combine pix from all files according to the bin
            pix_section = cat(2,pix_tb{:});
            obj.first_bin_to_process_ = last_bin_to_process+1;
            
            if h_log
                fprintf(h_log,' will save bins: [%d , %d]; ****** saving pixels: %d, pix left: %d\n',...
                    first_bin_to_proc,last_bin_to_process,size(pix_section,2),npix_left);
                fprintf(h_log,' cache contains: \n');
                for j=1:n_files
                    fprintf(h_log,'file %d; bin-range: [%d, %d] n full bins: %d\n',...
                        j,obj.bin_range_(1,j),obj.bin_range_(2,j),numel(obj.filled_bin_ind_{j}));
                end
            end
            
        end
        
    end
end

