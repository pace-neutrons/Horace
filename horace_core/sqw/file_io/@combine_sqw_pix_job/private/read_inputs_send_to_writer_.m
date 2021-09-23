function  npix_tot = read_inputs_send_to_writer_(obj,common_par,h_log)


% Unpack input structures
pix_comb_info    = obj.pix_combine_info_;
pos_pixstart     = pix_comb_info.pos_pixstart;



nbin = common_par.nbin;     % total number of bins
ibin_end = 0;
fprintf('***************** data reader: lab N%d\n',obj.labIndex);
mess_completion(nbin,5,1);   % initialize completion message reporting - only if exceeds time threshold

pix_buf_size=common_par.pix_buf_size;
mess_exch = obj.mess_framework;
npix_tot =0;
niter = 0;
% by chance, the number of the target worker which collects messages
% coincide with the combine mode number
targ_worker = obj.combine_mode;

while ibin_end<nbin
    
    % Refill buffer with next section of npix arrays from the input files
    ibin_start = ibin_end+1;
    [npix_per_bins,npix_in_bins,ibin_end]=...
        obj.get_npix_section(ibin_start,nbin,pix_buf_size);
    npix_per_bins = npix_per_bins';
    if h_log
        fprintf(h_log,'-------- npix_per_bins %d, bin_range: [%d, %d]; npix2process: %d\n',...
            numel(npix_per_bins ),ibin_start,ibin_end,npix_in_bins(end));
    end
    
    
    % Get the largest bin index such that the pixel information can be put in buffer
    % (We hold data for many bins in a buffer, as there is an overhead from reading each bin from each file separately;
    % only read when the bin index fills as much of the buffer as possible, or if reaches the end of the array of buffered npix)
    n_pix_2process = npix_in_bins(end);
    if n_pix_2process ==0 % send empty pix section message
        niter = niter+1;
        
        n_source = obj.labIndex-obj.reader_id_shift_;
        payload = obj.mess_struct_;
        payload.n_source = n_source;
        payload.bin_range= [ibin_start,ibin_end];
        
        pix_section_mess  = DataMessage(payload);
        [ok,err_mess]=mess_exch.send_message(targ_worker,pix_section_mess);
        if ok ~= MESS_CODES.ok
            error('HORACE:combine_sqw_pix_job:runtime_error',err_mess);
        end
        if h_log
            fprintf(h_log,'**** Processed ranges : [%d , %d], npix: %d#of%d\n',...
                ibin_start,ibin_end,0,0);
            fprintf(h_log,'     Step %d Sending pixels: %d; Total Sent: ************* %d\n',...
                niter,pix_section_mess.payload.npix,npix_tot);
        end
        continue;
    end
    npix_processed = 0;  % last pixel index for which data has been written to output file
    nbins_start = ibin_start;
    
    
    while npix_processed < n_pix_2process
        niter = niter+1;
        [npix_per_bin2_read,npix_processed,npix_per_bins,npix_in_bins,n_last_fit_bin] = ...
            obj.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size);
        
        [pix_section_mess,pos_pixstart]=...
            obj.read_pix_for_nbins_block(pos_pixstart,npix_per_bin2_read);
        %
        if n_last_fit_bin == 0
            nbins_end = nbins_start;
            pix_section_mess.payload.last_bin_completed = false;
        else
            nbins_end = nbins_start+n_last_fit_bin-1;
        end
        pix_section_mess.payload.bin_range = [nbins_start,nbins_end];
        npix_tot = npix_tot+pix_section_mess.payload.npix;
        %
        if h_log
            pix_section_mess.payload.messN = niter;
            fprintf(h_log,'**** Processed ranges : [%d , %d], npix: %d#of%d\n',...
                nbins_start,nbins_end,npix_processed,n_pix_2process);
            fprintf(h_log,'     Step %d Sending pixels: %d; Total Sent: ************* %d\n',...
                niter,pix_section_mess.payload.npix,npix_tot);
        end
        %
        [ok,err_mess]=mess_exch.send_message(targ_worker,pix_section_mess);
        if ok ~= MESS_CODES.ok
            error('COMBINE_SQW_PIX_JOB:runtime_error',err_mess);
        end
        nbins_start = nbins_end+1;
    end
    mess_completion(ibin_end);
    
end
mess_completion;
