function obj = put_sqw_data_pix_from_file_(obj, pix_comb_info,jobDispatcher)
% Write pixel information to file, reading that pixel information from a collection of other files
%
%   >> obj = put_sqw_data_pix_from_file (fid, infiles, npixstart, pixstart)
%
% Input:
% ------
% where
%   obj is initialized sqw_binfile_common object
%
%   pix_comb_info   is the pix_combine_info class with fields:
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
% jobDispatcher     if present and not empty contains initialized version of parallel framework
%                   used to write pixels in file using MPI-based algorithm.
%
% Notes:
% ------
%   Take care when using this function. No checks are performed that the input files have the
%  correct length of arrays npix and pix. It is assumed that this checking has already been done.
%
%   The reason for this function is that the output sqw structure may be too large to be held in memory.
%  This happens in particular during construction of the 'master' sqw file from a collection of sqw files, and
%  from taking large cuts from an sqw file (during which temporary files are written with the pixel information to
%  avoid out-of-memory problems).


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


% Get number of files
nfiles = pix_comb_info.nfiles;

% Check run_label:
relabel_with_fnum=pix_comb_info.relabel_with_fnum;
change_fileno  = pix_comb_info.change_fileno;

% size of buffer to hold pixel information, the log level and if use mex to
% build the result

[pmax,log_level] = config_store.instance().get_value('hor_config','mem_chunk_size','log_level');
use_mex = config_store.instance().get_value('hpc_config','combine_sqw_using');

pix_out_position = obj.pix_pos_;
if strcmp(use_mex,'mex_code')
    fout_name = fullfile(obj.filepath,obj.filename);
    pix_out_pos = obj.pix_position;
    obj = obj.fclose();
    n_bins = numel(pix_comb_info.npix_cumsum);
    [mess,infiles] = combine_files_using_mex(fout_name,n_bins,pix_out_pos,...
        pix_comb_info.infiles,pix_comb_info.pos_npixstart, pix_comb_info.pos_pixstart,pix_comb_info.run_label,...
        change_fileno,relabel_with_fnum);
    
    obj = obj.reopen_to_write();
    if isempty(mess)
        return
    else  % Mex combining have failed, try Matlab
        fout = obj.file_id_;
        fseek(fout,pix_out_position,'bof');
        check_error_report_fail_(obj,...
            ['Unable to move to the start of the pixel record in target file ',...
            obj.filename,' after mex-combine failed']);
    end
else
    fout = obj.file_id_;
    fseek(fout,pix_out_position,'bof');
    check_error_report_fail_(obj,...
        ['Unable to move to the start of the pixel record in target file ',...
        obj.filename,' after mex-combine failed']);
end


% Open all input files and move to the start of the pixel information
% [Currently opens all the input files simultaneously.  (TGP desktop PC on 1 July 2007 machine will open up to 509 files when tested)
% Opening all files may cause problems as I don't know what the reasonable default is, but I assume is faster than constantly opening
% and closing a hundred or more files]

if isnumeric(pix_comb_info.infiles)
    fid = pix_comb_info.infiles;   % copy fid
    for i=1:nfiles
        if isempty(fopen(fid(i)))
            error('SQW_FILE_IO:runtime_error',...
                'No open file N %d with file identifier %d',i,fid(i));
        end
    end
else
    fid=zeros(nfiles,1);
    for i=1:nfiles
        [fid(i),mess]=fopen(pix_comb_info.infiles{i},'r');
        if fid(i)<0
            for j=1:i-1; fclose(fid(j)); end    % close all the open input files
            error('SQW_FILE_IO:runtime_error',...
                'Unable to open all input files concurrently: %s',mess);
        end
    end
    clob = onCleanup(@()fcloser(fid));  % I hope this routine has full function visibility
    for i = 1:nfiles
        fseek(fid(i),pix_comb_info.pos_pixstart(i),'bof'); % Move directly to location of start of pixel data 
        check_error_report_fail_(obj,...                   % to ensure this is possible
            sprintf('Unable to move to the start of the pixel record for the  input file N%d after mex-combine failed',...
            i));
    end
end



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

t_io_total  = 0;
t_all_total=0;

nbin = numel(pix_comb_info.npix_cumsum);     % total number of bins

n_pix_written = 0;
ibin_end = 0;
je =combine_sqw_pix_job();
mess_completion(pix_comb_info.npix_cumsum(end),5,1);   % initialise completion message reporting - only if exceeds time threshold

pix_buf_size=pmax;
pos_pixstart = pix_comb_info.pos_pixstart;
while ibin_end<nbin
    
    % Refill buffer with next section of npix arrays from the input files
    ibin_start = ibin_end+1;
    [npix_per_bins,npix_in_bins,ibin_end]=combine_sqw_pix_job.get_npix_section(fid,pix_comb_info.pos_npixstart,ibin_start,nbin);
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
            combine_sqw_pix_job.nbin_for_pixels(npix_per_bins,npix_in_bins,npix_processed,pix_buf_size);
        
        if (log_level>1)
            tr = tic;
        end
        [pix_section,pos_pixstart]=...
            je.read_pix_for_nbins_block(fid,pos_pixstart,npix_per_bin2_read,...
            pix_comb_info.run_label,change_fileno,relabel_with_fnum);
        if (log_level>1)
            t_read=toc(tr);
            disp(['   ***time to read subcells from files: ',num2str(t_read),' speed: ',num2str(npix_processed*4*9/t_read/(1024*1024)),'MB/sec'])
        end
        
        %
        if (log_level>1)
            t_w = tic;
        end
        n_pix_written =je.write_pixels(fout,pix_section,n_pix_written);
        
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
% disp([' single bin write operations: ',num2str(nsinglebin_write)])
% disp(['     buffer write operations: ',num2str(nbuff_write)])


%
function  [mess,infiles] = combine_files_using_mex(fout_name,n_bin,pix_out_position,...
    infiles,npixstart, pixstart,runlabel,change_fileno,relabel_with_fnum)
% prepare input data for mex-combining and attempt to combine input data
% using mex.
nfiles = numel(infiles);
if isnumeric(infiles)
    close_files = true;
else
    close_files = false;
end
in_params=cell(nfiles,1);
for i=1:nfiles
    if close_files
        filename = fopen(infiles(i));
        fclose(filename);
    else
        filename = infiles{i};
    end
    if change_fileno
        if relabel_with_fnum
            file_id = i;   % set the run index to the file index
        else
            file_id = runlabel(i);  % offset the run index
        end
    else
        file_id = 0;
    end
    in_params{i} = struct('file_name',filename,...
        'npix_start_pos',npixstart(i),'pix_start_pos',pixstart(i),'file_id',file_id);
end

out_param = struct('file_name',fout_name ,...
    'npix_start_pos',NaN,'pix_start_pos',pix_out_position,'file_id',NaN);
%
[out_buf_size,log_level] = ...
    config_store.instance().get_value('hor_config',...
    'mem_chunk_size','log_level');
[buf_size,multithreaded_combining] = ...
    config_store.instance().get_value('hpc_config',...
    'mex_combine_buffer_size','mex_combine_thread_mode');

% conversion parameters include:
% n_bin        -- number of bins in the image array
% 1            -- first bin to start copying pixels for
% out_buf_size -- the size of output buffer to use for writing pixels
% change_fileno-- if pixel run id should be changed
% relabel_with_fnum -- if change_fileno is true, how to calculate the new pixel
%                  id -- by providing new id equal to filenum or by adding
%                  it to the existing num.
% num_ticks    -- approximate number of log messages to generate while
%                 combining files together
% buf size     -- buffer size -- the size of buffer used for each input file
%                 read operations
% multithreaded_combining - use multiple threads to read files
program_param = [n_bin,1,out_buf_size,log_level,change_fileno,relabel_with_fnum,100,buf_size,multithreaded_combining];
t_start=tic;
try
    if log_level>1
        fprintf(' Combining Task started at  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
    end
    combine_sqw(in_params,out_param ,program_param);
    mess = '';
catch ME
    mess = [ME.identifier,'::',ME.message];
    disp(['Error using C to combine files: ',mess,'; Reverted to Matlab'])
end
if log_level > 0
    te=toc(t_start);
    disp([' Task completed in ',num2str(te),' seconds'])
end
if log_level>1
    fprintf(' At the time  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
end

function fcloser(fid)
nfiles = numel(fid);
for j=1:nfiles
    fclose(fid(j));
end
