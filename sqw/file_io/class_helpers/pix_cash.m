classdef pix_cash
    % Implements cash for the pixels, transmitted through MPI messages
    % for combine_sqw_pix_job
    %
    properties(Dependent)
        last_bin_in_cash
        all_bin_range
    end
    
    properties(Access=protected)
        bin_range_   = [];
        
        filled_bin_ind_ =[];
        read_pix_cash_       = [];
        last_bin_to_process_ = 1;
    end
    
    methods
        function obj = pix_cash(n_workers)
            obj.bin_range_       =  zeros(2,n_workers-1);
            obj.filled_bin_ind_  =  cell(n_workers-1,1);
            obj.read_pix_cash_   =  cell(n_workers-1,1);
            
        end
        function dr = data_remain(obj,n_bins)
            dr = obj.bin_range_(2,:)<n_bins;
        end
        function lbp=get.last_bin_in_cash(obj)
            lbp = obj.last_bin_to_process_ -1;
        end
        function ran = get.all_bin_range(obj)
            ran = obj.bin_range_ ;
        end
        %
        function[obj] = push_messages(obj,mess_list,h_log_file)
            % retrieve pixel and bin information from messages and store
            % this information in message cash, together with information
            % from the previous messages
            %
            % Returns:
            % obj         -- with filled bin and pixels cash
            % last_bin_to_process -- the number of the last bin gathered
            %                        full information about contributing
            %                        pixels
            if ~exist('h_log_file','var')
                h_log_file = false;
            end
            
            n_files = numel(mess_list); % A message contains pixels from a files, combined on a worker, so may be considered as a "file"
            npix_received = 0;
            npix_stored = 0;
            for i=1:n_files
                % some messages may not be send any more.
                if isempty(mess_list{i})
                    continue;
                end
                pl = mess_list{i}.payload;
                if h_log_file
                    fprintf(h_log_file,' Message %d with range [%d , %d], filled in %d bins; has %d pixels\n;',...
                        i,pl.bin_range,numel(pl.filled_bin_ind),pl.npix);
                    if pl.bin_range(1)>obj.bin_range_(2,i)+1 % missed short message?
                        fprintf(h_log_file,'MessN %d, mes Range %d obj range %d\n',pl.messN,pl.bin_range(1),obj.bin_range_(2,i));
                        %data = labReceive(pl.messN,mess_list{i}.tag);
                    end
                    
                end
                if obj.bin_range_(2,i) <= obj.bin_range_(1,i)
                    obj.filled_bin_ind_{i}   = pl.filled_bin_ind;
                    obj.read_pix_cash_{i}    = pl.pix_tb;
                    obj.bin_range_(:,i)      = pl.bin_range;
                else
                    num_existing_bins = obj.bin_range_(2,i)-obj.bin_range_(1,i)+1;
                    npix_stored = npix_stored + sum(cellfun(@(x)numel(x),obj.read_pix_cash_{i}));
                    obj.filled_bin_ind_{i} =   [obj.filled_bin_ind_{i},(pl.filled_bin_ind+num_existing_bins)];
                    obj.read_pix_cash_{i}  =   [obj.read_pix_cash_{i},pl.pix_tb{:}];
                    obj.bin_range_(2,i)    = pl.bin_range(2);
                end
                npix_received = npix_received+pl.npix;
            end
            
            % debug and verification
            if h_log_file
                fprintf(h_log_file,' Npix in cash: %d, npix received %d, total %d\n',...
                    npix_stored,npix_received,npix_received+npix_stored);
                if any(obj.bin_range_(1,:) ~=obj.bin_range_(1,1))
                    error('PIX_CASH:runtime_error',...
                        'some lower bin ranges are not equal' )
                end
            end
            
        end
        %
        function [obj,pix_section] = pop_pixels(obj,h_log_file)
            % return the pixels block containing pixels for the bins
            % which have full information about pixels.
            %
            % clear cash from this information and keep only the
            % pixels for bin without full pixel information.
            
            if ~exist('h_log_file','var')
                h_log_file = false;
            end
            n_files = size(obj.bin_range_,2);
            first_bin_to_proc = obj.bin_range_(1,1); % they must be all equal;
            last_bin_to_process = min(obj.bin_range_(2,:));
            
            % number of bins in cash, containing full pixels information
            n_bins = last_bin_to_process  - first_bin_to_proc +1;
            
            
            % expanded index of the bins, containing any pixels
            bin_filled = false(n_bins,1);
            pix_tb = cell(n_files,n_bins);
            npix_left = 0;
            for i=1:n_files
                bic = obj.filled_bin_ind_{i};
                if isempty(bic)
                    continue;
                end
                n_bin_proc = find(bic>n_bins,1)-1;
                if isempty(n_bin_proc)
                    n_bin_proc = numel(bic);
                end
                pic = obj.read_pix_cash_{i};
                
                
                filled_bin_ind = bic(1:n_bin_proc);
                pix_tb(i,filled_bin_ind) = pic(1:n_bin_proc);
                if obj.bin_range_(2,i) > last_bin_to_process % store remaining bin and pixel info for future analysis
                    obj.filled_bin_ind_{i} = bic(n_bin_proc+1:end)-n_bins;
                    obj.read_pix_cash_{i}  = pic(n_bin_proc+1:end);
                    if h_log_file
                        npix_left = npix_left + sum(cellfun(@(x)numel(x),obj.read_pix_cash_{i}));
                    end
                else
                    obj.filled_bin_ind_{i} = [];
                    obj.read_pix_cash_{i}  = {};
                end
                obj.bin_range_(1,i)    = last_bin_to_process+1;
                
                bin_filled(filled_bin_ind) = true;
            end
            
            pix_tb = pix_tb(:,bin_filled); % accelerate combining by removing empty cells
            % combine pix from all files according to the bin
            pix_section = cat(2,pix_tb{:});
            obj.last_bin_to_process_ = last_bin_to_process+1;
            
            if h_log_file
                fprintf(h_log_file,' will save bins: [%d , %d]; ****** saing pixels: %d, pix left: %d\n',...
                    first_bin_to_proc,last_bin_to_process,size(pix_section,2),npix_left);
                fprintf(h_log_file,' cash contains: \n');
                for j=1:n_files
                    fprintf(h_log_file,'file %d; bin-range: [%d, %d] n full bins: %d\n',...
                        j,obj.bin_range_(1,j),obj.bin_range_(2,j),numel(obj.filled_bin_ind_{j}));
                end
            end
            
        end
        
    end
end

