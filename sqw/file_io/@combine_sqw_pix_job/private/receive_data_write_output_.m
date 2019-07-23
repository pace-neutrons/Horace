function receive_data_write_output_(obj,common_par,fout,data_providers,data_remain,h_log_file)
% common_par     -- the job info common for all parallel processes.
% fout           -- initialized handle for opened binary file to write data
% data_providers -- list of the lab nums will be sending data to the writer
%                   job
% data_remain    -- array of logical, indicating if a correspondent data
%                   provider is active (all true at the beginning)
% h_log_file     -- if > 0 - open handle to a log file opened on a head node
%                   to keep the information about the job progress. 


mpis = MPI_State.instance();
is_deployed = mpis.is_deployed;

nbin = common_par.nbin;     % total number of bins
npix = common_par.npixels;  % total number of pixels
disp('***************** data writer: ');
mess_completion(npix,5,1);   % initialise completion message reporting - only if exceeds time threshold
n_pix_written = 0;
ibin_end = 0;

mess_exch = obj.mess_framework;
npix_tot =0;
niter = 0;
prev_step=0;
while ibin_end<nbin
    [messages,task_ids] = mess_exch.receive_all(data_providers,'data');
    if h_log_file
        niter = niter+1;
        npix_received = 0;
        fprintf(h_log_file,'receiving:\n');
        for i=1:numel(messages)
            pl =  messages{i}.payload;
            fprintf(h_log_file,' lab %d mess N %d, npixels: %d; tid %d\n',...
                pl.lab,pl.messN,pl.npix,task_ids(i));
            
            npix_received = npix_received + pl.npix;
            
        end
        npix_tot = npix_tot+npix_received;
        
        fprintf(h_log_file,'************* Step %d Npix received: %d. Total received: %d\n',niter,npix_received,npix_tot);
    end
    
    if ~all(data_remain) % add empty providers to the list of messages
        exp_messages = cell(numel(data_remain),1);
        ic = 1;
        for i=1:numel(exp_messages)
            if data_remain(i)
                ind = task_ids(ic)-1;
                exp_messages(ind) = messages(ic);
                ic = ic+1;
            end
        end
        messages= exp_messages;
    end
    [obj,pix_section] = process_messages_fill_cache_(obj,messages);
    n_pix_written =obj.write_pixels(fout,pix_section,n_pix_written);
    
    ibin_end = obj.pix_cache_.last_bin_processed;
    if is_deployed
        step = 100*n_pix_written/npix;
        if floor(step)> prev_step            
            prev_step =floor(step);
            mpis.do_logging(step,100,[],[]);
        end
    end
    
    % Analyze what readers have not yet sent the whole
    % pixel data to the writer.
    data_remain = obj.pix_cache_.data_remain(nbin);
    data_providers = find(data_remain)+1;
    %
    if h_log_file
        fprintf(h_log_file,' Total npix written %d; ibinend:%d#out of %d\n',...
            n_pix_written,ibin_end,nbin);
        br = obj.pix_cache_.all_bin_range;
        
        fprintf(h_log_file,' bin ranges in cache:\n');
        for j=1:numel(data_remain)
            fprintf(h_log_file,' %d %d\n',br(1,j),br(2,j));
        end
    end
    mess_completion(n_pix_written);
end

if is_deployed
    mpis.do_logging(npix,npix,[],[]);
end
mess_completion;
