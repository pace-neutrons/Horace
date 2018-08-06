function  read_inputs_send_to_writer_(obj,common_par,pix_comb_info,fid,h_log_file)


% Unpack input structures
pos_pixstart     = pix_comb_info.pos_pixstart;
relabel_with_fnum= pix_comb_info.relabel_with_fnum;
change_fileno    = pix_comb_info.change_fileno;
run_label        = pix_comb_info.run_label;
filenum          = pix_comb_info.filenum;





nbin = common_par.nbin;     % total number of bins
ibin_end = 0;
fprintf('***************** data reader: lab N%d\n',obj.labIndex);
mess_completion(nbin,5,1);   % initialise completion message reporting - only if exceeds time threshold

pix_buf_size=common_par.pix_buf_size;
mess_exch = obj.mess_framework;
npix_tot =0;
niter = 0;

while ibin_end<nbin
    
    % Refill buffer with next section of npix arrays from the input files
    ibin_start = ibin_end+1;
    [npix_per_bins,npix_in_bins,ibin_end]=...
        obj.get_npix_section(fid,pix_comb_info.pos_npixstart,ibin_start,nbin,pix_buf_size);
    npix_per_bins = npix_per_bins';
    if h_log_file
        fprintf(h_log_file,'-------- npix_per_bins %d, bin_range: [%d, %d]; npix2process: %d\n',...
            numel(npix_per_bins ),ibin_start,ibin_end,npix_in_bins(end));
    end
    
    
    % Get the largest bin index such that the pixel information can be put in buffer
    % (We hold data for many bins in a buffer, as there is an overhead from reading each bin from each file separately;
    % only read when the bin index fills as much of the buffer as possible, or if reaches the end of the array of buffered npix)
    n_pix_2process = npix_in_bins(end);
    if n_pix_2process ==0 % send empty pix section message
        niter = niter+1;
        pix_section_mess  = aMessage('data');
        payload = struct('lab',obj.labIndex,'messN',niter,'npix',0,...
            'bin_range',[ibin_start,ibin_end],'pix_tb',[],...
            'filled_bin_ind',[]);
        pix_section_mess.payload = payload;
        [ok,err_mess]=mess_exch.send_message(1,pix_section_mess);
        if ok ~= MESS_CODES.ok
            error('COMBINE_SQW_PIX_JOB:runtime_error',err_mess);
        end
        if h_log_file
            fprintf(h_log_file,'**** Processed ranges : [%d , %d], npix: %d#of%d\n',...
                ibin_start,ibin_end,0,0);
            fprintf(h_log_file,'     Step %d Sending pixels: %d; Total Sent: ************* %d\n',...
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
            obj.read_pix_for_nbins_block(fid,pos_pixstart,npix_per_bin2_read,...
            filenum,run_label,change_fileno,relabel_with_fnum);
        nbins_end = nbins_start+n_last_fit_bin-1;
        pix_section_mess.payload.bin_range = [nbins_start,nbins_end];
        if h_log_file
            pix_section_mess.payload.messN = niter;
            npix_tot = npix_tot+pix_section_mess.payload.npix;
            fprintf(h_log_file,'**** Processed ranges : [%d , %d], npix: %d#of%d\n',...
                nbins_start,nbins_end,npix_processed,n_pix_2process);
            fprintf(h_log_file,'     Step %d Sending pixels: %d; Total Sent: ************* %d\n',...
                niter,pix_section_mess.payload.npix,npix_tot);
        end
        %
        [ok,err_mess]=mess_exch.send_message(1,pix_section_mess);
        if ok ~= MESS_CODES.ok
            error('COMBINE_SQW_PIX_JOB:runtime_error',err_mess);
        end
        nbins_start = nbins_end+1;
    end
    mess_completion(ibin_end);
    
end
mess_completion;
