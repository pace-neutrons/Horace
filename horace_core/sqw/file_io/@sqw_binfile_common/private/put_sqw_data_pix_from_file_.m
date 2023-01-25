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


% size of buffer to hold pixel information, the log level and if use mex to
% build the result

combine_algorithm = get(hpc_config,'combine_sqw_using');

pix_out_position = obj.pix_pos_;

switch combine_algorithm
  case 'mex_code'
    fout_name = fullfile(obj.filepath,obj.filename);
    pix_out_pos = obj.pix_position;
    obj = obj.fclose();
    n_bins = pix_comb_info.nbins;
    % Check run_label:
    relabel_with_fnum = pix_comb_info.relabel_with_fnum;
    change_fileno  = pix_comb_info.change_fileno;

    [mess,infiles] = combine_files_using_mex(fout_name,n_bins,pix_out_pos,...
                                             pix_comb_info.infiles,pix_comb_info.pos_npixstart, ...
                                             pix_comb_info.pos_pixstart,pix_comb_info.run_label,...
                                             change_fileno,relabel_with_fnum);

    obj = obj.reopen_to_write();
    if ~isempty(mess)
        fout = obj.file_id_;
        fseek(fout,pix_out_position,'bof');
        check_error_report_fail_(obj,...
                                 ['Unable to move to the start of the pixel record in target file ',...
                                  obj.filename,' after mex-combine failed']);

        je = combine_sqw_pix_job();
        je.write_npix_to_pix_blocks(fout,pix_out_position,pix_comb_info);
    end

  case 'mpi_code'

    pool_exist = exist('jobDispatcher','var') && ~isempty(jobDispatcher);
    if pool_exist
        % reuse existing parallel pool
        jd = jobDispatcher;
        pool_exist  = jd.is_initialized;
        if pool_exist
            n_workers = jd.cluster.n_workers;
        else
            n_workers  = get(hpc_config,'parallel_workers_number');
        end
    else
        fn = obj.filename;

        if numel(fn) > 8
            fn = fn(1:8);
        end

        job_name = ['combine_sqw_',fn];
        jd = JobDispatcher(job_name);
        n_workers = get(hpc_config,'parallel_workers_number');
    end

    fout_name = fullfile(obj.filepath,obj.filename);
    pix_out_pos = obj.pix_position;
    obj = obj.fclose();

    [common_par,loop_par] = ...
        combine_sqw_pix_job.pack_job_pars(pix_comb_info,fout_name,pix_out_pos,n_workers);

    if pool_exist
        [outputs,n_failed,~,jd] = jd.restart_job('combine_sqw_pix_job',...
                                                 common_par,loop_par,true,false);
    else
        [outputs,n_failed,~,jd] = jd.start_job('combine_sqw_pix_job',...
                                               common_par,loop_par,true,n_workers,false);
    end

    if n_failed > 0
        jd.display_fail_job_results(outputs,n_failed,n_workers,'WRITE_NSQW_TO_SQW:runtime_error');
    else
        pix_num_exchanged = [outputs{:}];
        if sum(pix_num_exchanged) ~= 2*pix_num_exchanged(1)
            warning('COMBINE_SQW_PIX_JOB:runtime_error',...
                ' Number of pixels sent by parallel workers sum(outputs(2:end)) not equal to the number of pixels, written to hdd outputs{1}');
            disp(pix_num_exchanged);
        end

        obj = obj.reopen_to_write();
    end

  case 'matlab'

    fout = obj.file_id_;
    je = combine_sqw_pix_job();
    je.write_npix_to_pix_blocks(fout,pix_out_position,pix_comb_info);
end

end

function  [mess,infiles] = combine_files_using_mex(fout_name,n_bin,pix_out_position,...
    infiles,npixstart, pixstart,runlabel,change_fileno,relabel_with_fnum)
% prepare input data for mex-combining and attempt to combine input data
% using mex.
nfiles = numel(infiles);

close_files = isnumeric(infiles);

in_params=cell(nfiles,1);
for i=1:nfiles
    if close_files
        filename = fopen(infiles(i));
        fclose(filename);
    else
        filename = infiles{i};
    end

    if change_fileno && relabel_with_fnum
        file_id = i;   % set the run index to the file index
    elseif change_fileno
        file_id = runlabel(i);  % set the run index to specified value
    else
        file_id = 0;
    end

    in_params{i} = struct('file_name',filename,...
                          'npix_start_pos',npixstart(i),...
                          'pix_start_pos',pixstart(i),...
                          'file_id',file_id);
end

out_param = struct('file_name',fout_name ,...
    'npix_start_pos',NaN,'pix_start_pos',pix_out_position,'file_id',NaN);

[out_buf_size,log_level] = get(hor_config,'mem_chunk_size','log_level');
[buf_size,multithreaded_combining] = get(hpc_config,'mex_combine_buffer_size','mex_combine_thread_mode');

% conversion parameters include:
% n_bin        -- number of bins in the image array
% 1            -- first bin to start copying pixels for
% out_buf_size -- the size of output buffer to use for writing pixels
% change_fileno-- if pixel run id should be changed
% relabel_with_fnum -- if change_fileno is true, how to calculate the new pixel
%                  id -- by providing new id equal to filenum or by
%                  assigning the new number provided to it
% num_ticks    -- approximate number of log messages to generate while
%                 combining files together
% buf size     -- buffer size -- the size of buffer used for each input file
%                 read operations
% multithreaded_combining - use multiple threads to read files
program_param = [n_bin,1,out_buf_size,log_level,change_fileno,relabel_with_fnum,100,buf_size,multithreaded_combining];

if log_level > 0
    t_start=tic;
end
if log_level>1
    fprintf(' Combining Task started at  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
end

try
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

end
