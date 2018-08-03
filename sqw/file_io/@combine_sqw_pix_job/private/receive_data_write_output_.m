function receive_data_write_output_(obj,common_par,fout,data_providers,data_remain,h_log_file)

mpis = MPI_State.instance();
is_deployed = mpis.is_deployed;

nbin = common_par.nbin;     % total number of bins
npix = common_par.npixels;  % total number of pixels

n_pix_written = 0;
ibin_end = 0;

mess_exch = obj.mess_framework;
npix_tot =0;
niter = 0;
while ibin_end<nbin
    messages = mess_exch.receive_all(data_providers,'data');
    if h_log_file
        niter = niter+1;
        npix_received = 0;
        fprintf(h_log_file,'receiving:\n');
        for i=1:numel(messages)
            pl =  messages{i}.payload;
            fprintf(h_log_file,' lab %d mess N %d, npixels: %d\n',...
                pl.lab,pl.messN,pl.npix);
            npix_received = npix_received +pl.npix;
        end
        npix_tot = npix_tot+npix_received;
        
        fprintf(h_log_file,'************* Step %d Npix received: %d. Total received: %d\n',niter,npix_received,npix_tot);
    end
    
    if ~all(data_remain) % add empty providers to the list of messages
        exp_messages = cell(numel(data_remain),1);
        ic = 1;
        for i=1:numel(exp_messages)
            if data_remain(i)
                exp_messages(i) = messages(ic);
                ic = ic+1;
            end
        end
        messages= exp_messages;
    end
    [obj,pix_section] = process_messages_fill_cash_(obj,messages);
    n_pix_written =obj.write_pixels(fout,pix_section,n_pix_written);
    
    ibin_end = obj.pix_cash_.last_bin_in_cash;
    if is_deployed
        step = 100*n_pix_written/npix;
        mpis.do_logging(step,100,[],[]);
    end
    
    % Analyze what readers have not yet sent the whole
    % pixel data to the writer.
    data_remain = obj.pix_cash_.data_remain(nbin);
    data_providers = find(data_remain)+1;
    %
    if h_log_file
        fprintf(h_log_file,' Total npix written %d; ibinend:%d#out of %d\n',...
            n_pix_written,ibin_end,nbin);
    end
    
end

if is_deployed
    mpis.do_logging(npix,npix,[],[]);
end
