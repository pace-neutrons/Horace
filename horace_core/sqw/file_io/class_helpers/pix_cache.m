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
    % bin_range -- 2 elements array, containing min-max indexes of bins,
    %              these pixels contribute to.
    % last_bin_completed (true, false)
    %           -- boolean, indicating that all pixels of the last
    %              bin are provided in last pix_tb cell or some of them
    %              have not fit the buffer and will be send in the
    %              following message
    % pix_tb    -- array, containing pix data sorted according to bins
    %
    % bin_edges -- the indexes of each first pixel in a bin.
    %              contribute to. I.e. if message contains
    %              pixels from bins 10-20,with one bin per pixels but
    %              bins 12 and 15 are empty, bin_edges will contains:
    %              1  2  3  3  4  5  5  6  7  8  9
    %              10 11 12 13 14 15 16 17 18 19 20 -- bin numbers
    properties(Dependent)
        % number of parallel readers providing the data.
        n_readers
        %
        % total number of bins the pixels are sorted into
        n_bins;
        %
        first_bin_to_process;
        %
        last_bin_processed
        
        % the array of containing the min and max bin numbers,
        % for the pixels, present in cache. size or the array is == [2,n_readers]
        % where the n_readers== n_workers -1 or n_workers -2 is the
        % number of workers, used to read data from the partial files.
        all_bin_range
        %
        npix_in_cache
    end
    
    properties(Access=protected)
        % number of parallel readers, providing data for combining
        n_readers_
        % total number of bins the pixels are sorted into
        n_bins_
        % the array of containing the min and max bin numbers,
        % for the pixels, present in cache. size or the array is == [2,n_readers]
        % where the n_readers== n_workers -1 or n_workers -2 is the
        % number of workers, used to read data from the partial files.
        bin_range_   = [];
        
        % a n_readers (n_workers-1[2]) cellarray, with each cell containing
        % pixels contributing to each non-empty bin currently in the cache
        read_pix_cache_       = {};
        
        % the indexes of
        % (in read_pix_cache_ above)
        bin_edges_ ={};
        
        % the number of the first bin to process when pop_pixels command is
        % invoked.
        first_bin_to_process_ = 1;
        
        % the boolean of n_readers size, containing true, if all pixels
        % of the last bin are stored in the cache or true if they are not
        last_bin_completed_ = [];
    end
    
    methods
        function obj = pix_cache(n_readers,n_bins)
            obj.n_readers_      = n_readers;
            obj.n_bins_         = n_bins;
            obj.bin_range_      =  zeros(2,n_readers);
            obj.bin_edges_      =  cell(n_readers,1);
            obj.read_pix_cache_ =  cell(n_readers,1);
            obj.last_bin_completed_ =true(n_readers,1);
        end
        %
        function ds = data_surces_remain(obj)
            % return list of data sources, which still have not presented all
            % appropriate pixels to cache.
            
            % indexes of incompleted sources. Either not all bin range
            % processed or las bin in the range is incomplete
            t_incompl = obj.bin_range_(2,:)< obj.n_bins |...
                ~obj.last_bin_completed_';
            ds = 1:obj.n_readers;
            ds  = ds(t_incompl);
        end
        function lbp=get.last_bin_processed(obj)
            lbp = obj.first_bin_to_process_ -1;
        end
        %
        function ran = get.all_bin_range(obj)
            ran = obj.bin_range_ ;
        end
        %
        function nbin = get.first_bin_to_process(obj)
            nbin = obj.first_bin_to_process_;
        end
        %
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
        %
        function nwk = get.n_readers(obj)
            nwk = obj.n_readers_;
        end
        %
        function nbin = get.n_bins(obj)
            nbin = obj.n_bins_;
        end
        %
        function npc = get.npix_in_cache(obj)
            npc = sum(cellfun(@(x)(size(x,2)),obj.read_pix_cache_));
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
            if ~exist('h_log','var') || isempty(h_log)
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
                        '********************  Message %d with range [%d , %d], has %d pixels\n;',...
                        i,pl.bin_range,pl.npix);
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
                    %[n_source,cell_data] =  obj.split_data_to_cells(pl);
                    if isempty(obj.read_pix_cache_{n_source})
                        obj.read_pix_cache_{n_source}    = pl.pix_data;
                        obj.bin_edges_{n_source}         = pl.bin_edges;
                        obj.bin_range_(:,n_source)       = pl.bin_range;
                    else
                        if h_log
                            npix_stored = npix_stored + sum(cellfun(@(x)numel(x),obj.read_pix_cache_{n_source }));
                        end
                        % pixels left in cache
                        pc = obj.read_pix_cache_{n_source};
                        % combine pixel caches and bin ranges of all
                        % messages
                        bin_edges_exist = obj.bin_edges_{n_source};
                        bin_range = obj.bin_range_(:,n_source);
                        bin_edges_end   = bin_edges_exist(end);
                        if bin_range(2) == pl.bin_range(1) % two parts of the same bin are combined
                            bin_edges       = [bin_edges_exist(1:end-1);pl.bin_edges(2:end)+bin_edges_end-1];
                        else
                            bin_edges       = [bin_edges_exist(1:end-1);pl.bin_edges+bin_edges_end-1];
                        end
                        obj.bin_edges_{n_source}      = bin_edges;
                        
                        
                        obj.read_pix_cache_{n_source} =[pc,pl.pix_data];
                        
                        obj.bin_range_(2,n_source)    = pl.bin_range(2);
                        if numel(bin_edges)-1 ~= obj.bin_range_(2,n_source)-obj.bin_range_(1,n_source)+1
                            % its a bug
                            error('PIX_CAHE:runtime_error',...
                                'inconsistency between number of bin edges and bin range for source %d',n_source);
                        end
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
            
            if ~exist('h_log','var')  || isempty(h_log)
                h_log = false;
            end
            n_mess = size(obj.bin_range_,2);
            first_bin_to_proc   = min(obj.bin_range_(1,:)); %
            last_bin_to_process = min(obj.bin_range_(2,:));
            
            
            % indexes of bins in cache, containing full pixels information:
            bins_proc   = first_bin_to_proc:last_bin_to_process;
            n_bins_proc = numel(bins_proc);
            
            
            pix_tb = cell(n_mess,n_bins_proc);
            
            next_bin_to_proc = last_bin_to_process+1;
            for i=1:n_mess
                % array of size(bins)+1 numbering the ranges of the pixels
                % belonging to each bin
                edges = obj.bin_edges_{i};
                if isempty(edges)
                    % if this happens, we assume no pixels for this bin range
                    % will be received from this source any more. We
                    % progress the bin range counter.
                    obj.bin_range_(:,i) = next_bin_to_proc;
                    continue;
                end
                if size(edges,2)>1
                    edges = edges';
                end
                
                nbin = obj.bin_range_(1,i):obj.bin_range_(2,i);
                select = ismember(nbin,bins_proc);
                nbin_selected = nbin(select);
                pix_ind = nbin_selected  -(first_bin_to_proc-1);
                bin_ind = nbin_selected -(obj.bin_range_(1,i)-1);
                
                
                pic   = obj.read_pix_cache_{i};
                %
                left  = edges(bin_ind);
                if isempty(left)% unbalanced bins and this file does not
                    %contribute to current combined bin
                    continue;
                end
                
                if last_bin_to_process<obj.bin_range_(2,i) % some bins info
                    % should remain in cache
                    right = edges(bin_ind+1)-1;
                    % last processed bin number
                    last_bin_num = last_bin_to_process+1;
                    obj.bin_range_(1,i)    = last_bin_num;
                    % select remaining bins
                    last_sel_edge_ind = numel(bin_ind)+1;
                    obj.bin_edges_{i} = edges(last_sel_edge_ind:end)-(edges(last_sel_edge_ind)-1);
                    obj.read_pix_cache_{i} = pic(:,right(end)+1:end);
                else
                    right = edges(2:end)-1;
                    last_bin_num = nbin(end);
                    if obj.last_bin_completed_(i)
                        obj.bin_range_(1,i)    = last_bin_num + 1;
                    else
                        obj.bin_range_(1,i)    = last_bin_num;
                    end
                    
                    obj.bin_edges_{i} = [];
                    obj.read_pix_cache_{i}  = [];
                end
                if obj.bin_range_(2,i)< obj.bin_range_(1,i)
                    obj.bin_range_(2,i) =obj.bin_range_(1,i);
                    if obj.last_bin_completed_(i) && ...
                            obj.bin_range_(2,i)<=obj.n_bins_ % we have not actually had
                        % last bin the next bin data have never been placed
                        % in cache
                        obj.last_bin_completed_(i) = false;
                    end
                end
                
                
                pix_tb(i,pix_ind) = arrayfun(@(x)(pic(:,left(x):right(x))),...
                    bin_ind,'UniformOutput',false);
                
                %
                next_bin_to_proc = min(next_bin_to_proc,obj.bin_range_(1,i));
            end
            
            % combine pix from all files according to the bin
            pix_section = cat(2,pix_tb{:});
            obj.first_bin_to_process_ = next_bin_to_proc;
            
            if h_log
                npix_left = obj.npix_in_cache;
                fprintf(h_log,' will save bins: [%d , %d]; ****** saving pixels: %d, pix left in cahce: %d\n',...
                    first_bin_to_proc,last_bin_to_process,size(pix_section,2),npix_left);
                fprintf(h_log,' cache contains: \n');
                for j=1:n_mess
                    fprintf(h_log,'file %d; bin-range: [%d, %d], last bin completed: %u\n',...
                        j,obj.bin_range_(1,j),obj.bin_range_(2,j),obj.last_bin_completed_(j));
                end
            end
            
        end
    end
end

