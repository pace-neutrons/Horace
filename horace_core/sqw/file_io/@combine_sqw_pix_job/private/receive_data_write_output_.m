function n_pix_written = receive_data_write_output_(obj,common_par,h_log)
% common_par     -- the job info common for all parallel processes.
% h_log          -- if > 0 - the open handle to an opened log file
%                   to report information about the job progress.
% Returns
% n_pix_written  -- number of pixels written to the file
%

mpis = MPI_State.instance();
is_deployed = mpis.is_deployed;

% fout           -- initialized handle for opened binary file to write data
fout = obj.fout_;
%
n_bins = common_par.nbin;     % total number of bins
npix = common_par.npixels;  % total number of pixels
if h_log
    disp('***************** data writer: ');
end
mess_completion(npix,5,1);   % initialize completion message reporting - only if exceeds time threshold
n_pix_written = 0;


mess_exch = obj.mess_framework;
pix_cache = obj.pix_cache_;
npix_tot =0;
niter = 0;
prev_step=0;

data_providers = pix_cache.data_surces_remain()+ obj.reader_id_shift_;
if h_log
    disp('***************** QUERYING DATA PROVIDERS:');
    disp(data_providers);
end

while ~isempty(data_providers)|| pix_cache.npix_in_cache ~= 0
    %
    if isempty(data_providers)
        messages = {};
    else
        messages = mess_exch.receive_all(data_providers,'data');
    end
    %
    if h_log
        [npix_tot,niter]=print_receive_statistics(h_log,messages,npix_tot,niter);
    end
    %
    pix_cache = pix_cache.push_messages(messages,h_log);
    [pix_cache,pix_section] = pix_cache.pop_pixels(h_log);
    %
    if h_log
        fprintf(h_log,' Saving n_pixels: %d\n',size(pix_section,2));
    end
    n_pix_written =obj.write_pixels(pix_section,n_pix_written);
    
    ibin_end = pix_cache.last_bin_processed;
    if is_deployed
        step = 100*n_pix_written/npix;
        if floor(step)> prev_step
            prev_step =floor(step);
            mpis.do_logging(step,100,[],[]);
        end
    end
    
    % Analyze what readers have not yet sent the whole
    % pixel data to the writer.
    data_providers = pix_cache.data_surces_remain() + obj.reader_id_shift_;
    %
    if h_log
        fprintf(h_log,...
            '********************  Total npix written %d; ibinend:%d#out of %d\n',...
            n_pix_written,ibin_end,n_bins);
        br = pix_cache.all_bin_range;
        
        fprintf(h_log,...
            '********************  bin ranges in cache:\n');
        for j=1:size(br,2)
            fprintf(h_log,'********************  %d %d\n',br(1,j),br(2,j));
        end
    end
    mess_completion(n_pix_written);
end
obj.pix_cache_ = pix_cache;

if is_deployed
    mpis.do_logging(npix,npix,[],[]);
end
mess_completion;

function [npix_tot,niter]=print_receive_statistics(h_log,messages,npix_tot,niter)
% print statistics describing current received messages
%
niter = niter+1;
fprintf(h_log,...
    '******************** receiving:\n');
for i=1:numel(messages)
    pl =  messages{i}.payload;
    
    fprintf(h_log,...
        '******************** lab %d mess N %d, npixels: %d; tid %d\n',...
        pl.n_source,pl.messN,pl.npix,task_ids(i));
    
    npix_received = npix_received + pl.npix;
end
npix_tot = npix_tot+npix_received;

fprintf(h_log,...
    '******************** Step %d Npix received: %d. Total received: %d\n',...
    niter,npix_received,npix_tot);
