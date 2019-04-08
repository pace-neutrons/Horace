function write_npix_to_pix_blocks_(obj,fout,pix_out_position,pix_comb_info)
% take pixels from the contributing files and place them into final sqw
% file pixels block
%
% Inputs:
% fout             -- filehandle or filename of target sqw file
% pix_out_position -- the position where pixels should be located in the
%                     target binary file
% pix_comb_info    -- the class containing the information about the input
%                     files to combine, namely the fields:
%
%   infiles         Cell array of file names, or array of file identifiers of open files, from
%                   which to accumulate the pixel information
%   pos_npixstart   Position (in bytes) from start of file of the start of the field npix
%   pos_pixstart    Position (in bytes) from start of file of the start of the field pix
%   npix_cumsum     Accumulated sum of number of pixels per bin across all the files
%   run_label       Indicates how to re-label the run index (pix(5,...)
%                       'fileno'        relabel run index as the index of the file in the list infiles
%                       'nochange'      use the run index as in the input file
%                        numeric array  offset run numbers for ith file by ith element of the array
%                   This option exists to deal with three limiting cases:
%                    (1) The run index is already written to the files correctly indexed into the header
%                       e.g. as when temporary files have been written during cut_sqw
%                    (2) There is one file per run, and the run index in the header block is the file
%                       index e.g. as in the creating of the master sqw file
%                    (3) The files correspond to several runs in general, which need to
%                       be offset to give the run indices into the collective list of run parameters
%
% As the result -- writes combined pixels block to the ouput sqw file.
%
% $Revision:: 1720 ($Date:: 2019-04-08 16:49:36 +0100 (Mon, 8 Apr 2019) $)
%

log_level = config_store.instance().get_value('herbert_config','log_level');
pmax = config_store.instance().get_value('hor_config','mem_chunk_size');


if isnumeric(fout)
    filename = fopen(fout);
else
    filename = fout;
    fout = fopen(filename,'wb+');
end
fseek(fout,pix_out_position,'bof');
check_error_report_fail_(fout,...
    ['Unable to move to the start of the pixel record in THE target file ',...
    filename ,' starting matlab-combine']);



% Get number of files
fid = verify_and_reopen_input_files_(pix_comb_info);
% Always close opened files on the procedure completion
clob = onCleanup(@()fcloser_(fid));  %


% Write the pixel information to the file
%  The algorithm works as follows:
%       - Outer loop: deals with each of the bins in the grid for the output file in turn
%       - Inner loop: for each input file in turn, read the corresponding pixel information for that bin and then
%                     write to the output file
%  This is done because in general there is simply insufficient memory to hold the whole contents of all the files
%
%  We cannot read the number of pixels in each bin from all the individual input files, as we do not have enough
%  memory even for that, in general. We need to read these in, a section at a time, into a buffer.
% (For example, if 50^4 grid, 300 files then array size of npix= 8*300*50^4 = 15GB).

%profile on

% Unpack input structures
relabel_with_fnum= pix_comb_info.relabel_with_fnum;
change_fileno    = pix_comb_info.change_fileno;
run_label        = pix_comb_info.run_label;
filenum          = pix_comb_info.filenum;

% time counters
t_io_total  = 0;
t_all_total=0;

nbin = pix_comb_info.nbins;     % total number of bins

n_pix_written = 0;
ibin_end = 0;

mess_completion(pix_comb_info.npixels,5,1);   % initialise completion message reporting - only if exceeds time threshold

pix_buf_size=pmax;
pos_pixstart = pix_comb_info.pos_pixstart;
while ibin_end<nbin
    
    % Refill buffer with next section of npix arrays from the input files
    ibin_start = ibin_end+1;
    [npix_per_bins,npix_in_bins,ibin_end]=obj.get_npix_section(fid,pix_comb_info.pos_npixstart,ibin_start,nbin);
    npix_per_bins = npix_per_bins';
    
    % Get the largest bin index such that the pixel information can be put in buffer
    % (We hold data for many bins in a buffer, as there is an overhead from reading each bin from each file separately;
    % only read when the bin index fills as much of the buffer as possible, or if reaches the end of the array of buffered npix)
    n_pix_2process = npix_in_bins(end);
    npix_processed = 0;  % last pixel index for which data has been written to output file
    while npix_processed < n_pix_2process
        if (log_level>1)
            t_all=tic;
        end
        
        [npix_per_bin2_read,npix_processed,npix_per_bins,npix_in_bins] = ...
            obj.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size);
        
        if (log_level>1)
            tr = tic;
        end
        [pix_section,pos_pixstart]=...
            obj.read_pix_for_nbins_block(fid,pos_pixstart,npix_per_bin2_read,...
            filenum,run_label,change_fileno,relabel_with_fnum);
        if (log_level>1)
            t_read=toc(tr);
            disp(['   ***time to read subcells from files: ',num2str(t_read),' speed: ',num2str(npix_processed*4*9/t_read/(1024*1024)),'MB/sec'])
        end
        
        %
        if (log_level>1)
            t_w = tic;
        end
        n_pix_written =obj.write_pixels(fout,pix_section,n_pix_written);
        
        if (log_level>1)
            t_write = toc(t_w);
            t_total=toc(t_all);
            t_io   = t_write+t_read;
            t_io_total = t_io_total+t_io;
            t_all_total = t_all_total+t_total;
            disp(['   ***time to write pixels: ',num2str(t_write),' speed: ',num2str(npix_processed*4*9/t_write/(1024*1024)),'MB/sec'])
            disp(['   ***IO time to total time ratio: ',num2str(100*t_io/t_total),'%'])
        end
        
        mess_completion(n_pix_written)
    end
end

%profile off
%profile viewer
clear clob;
mess_completion
if (log_level>1)
    file_size = n_pix_written*9*4/(1024*1024);
    disp(['***   IO time to total time ratio: ',num2str(100*t_io_total/t_all_total),'%'])
    disp(['*** Size of the generated file is: ',num2str(file_size),'MB'])
end
