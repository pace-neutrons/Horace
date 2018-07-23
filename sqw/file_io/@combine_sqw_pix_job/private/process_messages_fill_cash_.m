function  [obj,pix_section] = process_messages_fill_cash_(obj,messages)
% processed the received messages, forms and returns combined data block to write and
% stores the pixels corresponding to not fully filled bins into the pixels
% cash.

last_bin_to_process = inf;
n_files = numel(messages); % A message contains pixels from a files, combined on a worker, so may be considered as a "file"

for i=1:n_files
    if isempty(messages{i})
        continue;
    end
    pl = messages{i}.payload;
    if obj.h_log_file
        fprintf(obj.h_log_file,' Message %d with range [%d , %d], filled in %d bins\n;',i,pl.bin_range,numel(pl.filled_bin_ind));
    end
    if obj.num_bin_in_tail_(i) <= 0
        obj.filled_bin_ind_{i}   = pl.filled_bin_ind;
        obj.read_pix_cash_{i}    = pl.pix_tb;
    else
        obj.filled_bin_ind_{i} = [obj.filled_bin_ind_{i},(pl.filled_bin_ind+obj.num_bin_in_tail_(i))];
        obj.read_pix_cash_{i}  =   [obj.read_pix_cash_{i},pl.pix_tb{:}];
    end
    obj.max_bins_num_cash_(i)   = pl.bin_range(2);
    
    if pl.bin_range(2)  < last_bin_to_process
        last_bin_to_process  = pl.bin_range(2);
    end
end
% number of bins in cash, received pixels information
n_bins = last_bin_to_process  - obj.last_bins_processed_;

% number of bins left for processing at next steps as some workers
% processed more bins then others
obj.num_bin_in_tail_    = obj.max_bins_num_cash_-last_bin_to_process;
% expanded index of the bins, containing any pixels
bin_filled = false(n_bins,1);
pix_tb = cell(n_files,n_bins);
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
    if n_bin_proc < numel(bic) % store remaining bin and pixel info for future analysis
        obj.filled_bin_ind_{i} = bic(n_bin_proc+1:end)-n_bins;
        obj.read_pix_cash_{i}  = pic(n_bin_proc+1:end);
    else
        obj.filled_bin_ind_{i} = [];
        obj.read_pix_cash_{i}  = {};
    end
    
    bin_filled(filled_bin_ind) = true;
end
if obj.h_log_file
    fprintf(obj.h_log_file,' will save bins: [%d , %d];',obj.last_bins_processed_,last_bin_to_process);
end
obj.last_bins_processed_ = last_bin_to_process;


pix_tb = pix_tb(:,bin_filled); % accelerate combining by removing empty cells
% combine pix from all files according to the bin
pix_section = cat(2,pix_tb{:});
if obj.h_log_file
    fprintf(obj.h_log_file,'  n_pixels: %d\n',size(pix_section,2));
end

