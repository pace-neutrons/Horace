function n_pix_written = receive_combined_write_output_(obj,common_par,h_log)
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
npix_tot =0;
niter = 0;
prev_step=0;

if h_log
    disp('***************** QUERYING DATA PROVIDERS:');
    disp(data_providers);
end

while npix>n_pix_written
    %
    message = mess_exch.receive_all(2,'data');
    %
    pix_section = message{1}.payload;
    %
    %
    if h_log
        npix = size(pix_section,2);
        [npix_tot,niter]=print_receive_statistics(h_log,npix,npix_tot,niter);
    end
    %
    n_pix_written =obj.write_pixels(pix_section,n_pix_written);
    
    
    if is_deployed
        step = 100*n_pix_written/npix;
        if floor(step)> prev_step
            prev_step =floor(step);
            mpis.do_logging(step,100,[],[]);
        end
    end
    
    if h_log
        fprintf(h_log,...
            '********************  Total npix written %d\n',...
            n_pix_written);
        
    end
    mess_completion(n_pix_written);
end


if is_deployed
    mpis.do_logging(npix,npix,[],[]);
end
mess_completion;

function [npix_tot,niter]=print_receive_statistics(h_log,npix_received,npix_tot,niter)
% print statistics describing current received messages
%
niter = niter+1;
fprintf(h_log,...
    '******************** receiving from lab2 %d npixels :\n',npix_received);

npix_tot = npix_tot+npix_received;

fprintf(h_log,...
    '******************** Step %d Npix received: %d. Total received: %d Saving received\n',...
    niter,npix_received,npix_tot);
