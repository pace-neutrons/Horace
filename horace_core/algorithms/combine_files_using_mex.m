function  [mess,infiles] = combine_files_using_mex(fout_name,n_bin,pix_out_position,...
    infiles,npixstart, pixstart,runlabel,change_fileno,relabel_with_fnum)
% prepare input data for mex-combining and attempt to combine input data
% using mex.
%
% Inputs:
% fout_name  -- name of the output file
% n_bin      -- number of bins the images to combine contain
% pix_out_position
%            -- the position to start writing pixels at
% infiles    -- cellarray of full names of the input files to combine
% npixstart  -- array (size of numel(infiles) defining physical postitions
%               of npix data in each input file to combine.
% pixstart   -- array (size of numel(infiles) defining physical postitions
%               of pix data in each input file to combine.
%
% runlabel,change_fileno,relabel_with_fnum
%            -- the variables controlling the processing of the run_indexes
%               of combined pixels
%

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
    fprintf(' Combining Task started at:  %s\n',string(datetime('now')));
end

try
    combine_sqw(in_params,out_param ,program_param);
    mess = '';
catch ME
    mess = [ME.identifier,'::',ME.message];
    disp(['Error using C to combine files: ',mess])
    rethrow(ME);
end

if log_level > 0
    te=toc(t_start);
    disp([' Task completed in ',num2str(te),' seconds'])
end
if log_level>1
    fprintf(' At the time: %s\n',string(datetime('now')));
end

end
