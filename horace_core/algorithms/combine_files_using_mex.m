function  [mess,infiles] = combine_files_using_mex(fout_name,pix_comb_info, ...
    pix_out_position,runlabel,change_fileno,relabel_with_fnum)
% prepare input data for mex-combining and attempt to combine input data
% using mex.
%
% Inputs:
% fout_name  -- name of the output file
% pix_comb_info 
%            -- instance of pixfile_combine_info class, containing
%               information about tmp files to assemble together, 
%               Namely:
%            n_bin     - number of bins the images to combine contain
%            infiles   - cellarray of full names of the input files to combine
%            npixstart - array (size of numel(infiles) defining physical positions
%                        of npix data in each input file to combine.
%            pixstart  - array (size of numel(infiles) defining physical positions
%                         of pix data in each input file to combine.

% pix_out_position
%             -- the position to start writing pixels at
%
% runlabel,change_fileno,relabel_with_fnum
%            -- the variables controlling the processing of the run_indexes
%               of combined pixels
%
% obj.pix_combine_info.nbins, ...
%                     obj.pixout_start_pos_,obj.pix_combine_info.infiles, ...
%                     obj.pix_combine_info.pos_npixstart,obj.pix_combine_info.pos_pixstart,

infiles = pix_comb_info.infiles;
nfiles = numel(infiles);

close_files = isnumeric(infiles);
filenum_provided = change_fileno && ~isempty(runlabel);

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
                          'npix_start_pos',pix_comb_info.pos_npixstart(i),...
                          'pix_start_pos',pix_comb_info.pos_pixstart(i),...
                          'file_id',double(file_id));
end

out_param = struct( ...          % filepar description of the output file
    'file_name',fout_name ,...   % output file name to write pixes
    'npix_start_pos',0, ...      % not used. Has been recalculated and written before
    'pix_start_pos',pix_out_position, ... % position where to write pixels 12 bytes before this position is the position of the pix metadata
    'file_id',NaN);

[out_buf_size,log_level] = get(hor_config,'mem_chunk_size','log_level');
[buf_size,multithreaded_combining] = get(hpc_config,'mex_combine_buffer_size','mex_combine_thread_mode');

% conversion parameters include:
% n_bin        -- number of bins in the image array
% 1            -- first bin to start copying pixels for
% out_buf_size -- the size of output buffer to use for writing pixels
% change_fileno-- if pixel run id should be changed
% filenum_provided -- if change_fileno is true, how to calculate the new pixel
%                  id -- by providing new id equal to file-num or by
%                  assigning the new number provided to it
% num_ticks    -- approximate number of log messages to generate while
%                 combining files together
% buf size     -- buffer size -- the size of buffer used for each input file
%                 read operations
% multithreaded_combining - use multiple threads to read files
program_param = [pix_comb_info.nbins,1,out_buf_size,log_level,change_fileno,filenum_provided,100,buf_size,multithreaded_combining];

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
