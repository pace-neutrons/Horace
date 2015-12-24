function [mess,fid_input] = put_sqw_data_pix_from_file (fout, infiles, pos_npixstart, pos_pixstart, npix_cumsum, run_label)
% Write pixel information to file, reading that pixel information from a collection of other files
%
%   >> mess = put_sqw_data_pix_from_file (fid, infiles, npixstart, pixstart)
%
% Input:
% ------
%   fout            File identifier of output file (opened for binary writing)
%   infiles         Cell array of file names, or array of file identifiers of open files, from
%                  which to accumulate the pixel information
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
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%
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
nfiles = length(infiles);

% Check run_label:
if ischar(run_label)
    if strcmpi(run_label,'nochange')
        change_fileno=false;
    elseif strcmpi(run_label,'fileno')
        change_fileno=true;
        fileno=true;
    else
        mess='Invalid value for argument run_label';
        return
    end
elseif isnumeric(run_label) && numel(run_label)==nfiles
    change_fileno=true;
    fileno=false;
else
    mess='Invalid contents for argument run_label';
    return
end
fid_input = false;
% size of buffer to hold pixel information, the log level and if use mex to
% build the result
[pmax,log_level,use_mex] = get(hor_config,'mem_chunk_size','log_level','use_mex');
if use_mex
    pix_out_position = ftell(fout);
    fout_name = fopen(fout);
    fclose(fout);
    n_bins = numel(npix_cumsum);
    [mess,infiles] = combine_files_using_mex(fout_name,n_bins,pix_out_position,...
                     infiles,pos_npixstart, pos_pixstart,run_label,change_fileno,fileno);
    if isempty(mess)
        fid_input = true;
        return
    else  % Mex combining have failed, try Matlab
        fout = fopen(fout_name,'rb+');
        if (fout<0)
            mess=['Unable to reopen output file: ',fout_name,'with all necessary permissions'];
            return
        end
        status = fseek(fout,pix_out_position,'bof');
        if status<0
            mess=['Error finding location of pixel data in output file: ',fout_name];
            fclose(fout);
            return
        end        
    end
end


% Open all input files and move to the start of the pixel information
% [Currently opens all the input files simultaneously.  (TGP desktop PC on 1 July 2007 machine will open up to 509 files when tested)
% Opening all files may cause problems as I don't know what the reasonable default is, but I assume is faster than constantly opening
% and closing a hundred or more files]

if isnumeric(infiles)
    fid = infiles;   % copy fid
    for i=1:nfiles
        if isempty(fopen(fid(i)))
            mess = 'No open file with given file identifier';
            return
        end
    end
    close_input_files = false;
else
    fid=zeros(nfiles,1);
    for i=1:nfiles
        [fid(i),mess]=fopen(infiles{i},'r');
        if fid(i)<0
            for j=1:i-1; fclose(fid(j)); end    % close all the open input files
            mess=['Unable to open all input files concurrently: ',mess];
            return
        end
        status=fseek(fid(i),pos_pixstart(i),'bof'); % Move directly to location of start of pixel data
        if status<0;
            for j=1:i-1; fclose(fid(j)); end;
            mess=['Error finding location of pixel data in file ',infiles{i}];
            return
        end
    end
    close_input_files = true;
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

nbin = numel(npix_cumsum);                  % total number of bins
ibin_end=0;                                 % initialise the value of the largest element number of npix that is stored
ibin_lastflush=0;                           % last bin index for which data has been written to output file
npix_lastflush=0;                           % last pixel index for which data has been written to output file
file_size     =0;

nsinglebin_write = 0;
nbuff_write = 0;
mess_completion(npix_cumsum(end),5,1);      % initialise completion message reporting - only if exceeds time threshold
while ibin_end<nbin
    
    % Refill buffer with next section of npix arrays from the input files
    ibin_start = ibin_end+1;
    [npix_section,ibin_end,mess]=get_npix_section(fid,pos_npixstart,ibin_start,nbin);
    if ~isempty(mess)
        if close_input_files; for j=1:nfiles; fclose(fid(j)); end; end;
        mess = ['Error reading section of npix array in file %s \n %s',infiles{i},mess];
        return
    end
    % Get the largest bin index such that the pixel information can be put in buffer
    % (We hold data for many bins in a buffer, as there is an overhead from reading each bin from each file separately;
    % only read when the bin index fills as much of the buffer as possible, or if reaches the end of the array of buffered npix)
    while ibin_lastflush < ibin_end
        if (log_level>1)
            t_all=tic;
        end
        ibin = min(ibin_end,upper_index(npix_cumsum, npix_lastflush+pmax));
        if ibin==ibin_lastflush     % catch case when buffer cannot hold data for just the one bin
            ibin = ibin+1;
            for i=1:nfiles
                npix_in_bin = npix_section{i}(ibin-ibin_start+1);
                if npix_in_bin>0
                    [pix,count,ok,mess] = fread_catch(fid(i),[9,npix_in_bin],'*float32');
                    if ~all(ok);
                        if close_input_files; for j=1:nfiles; fclose(fid(j)); end; end;
                        mess = ['Error reading pixel data for bin ',num2str(ibin),' in file ',infiles{i},' : ',mess];
                        return
                    end
                    if change_fileno
                        if fileno
                            pix(5,:)=i;   % set the run index to the file index
                        else
                            pix(5,:)=pix(5,:)+run_label(i);     % offset the run index
                        end
                    end
                    fwrite(fout,pix,'float32');
                end
            end
            nsinglebin_write = nsinglebin_write + 1;
        else    % can hold data for at least one bin in buffer
            % Get information about number of pixels to be read from all the files
            nbin_flush = ibin-ibin_lastflush;           % number of bins read into buffer
            npix_flush = zeros(nbin_flush,nfiles);      % to hold the no. pixels in each bin of the section we will write
            for i=1:nfiles
                npix_flush(:,i) = npix_section{i}(ibin_lastflush-ibin_start+2:ibin-ibin_start+1);
            end
            npix_in_files= sum(npix_flush,1);           % number of pixels to be read from each file
            % start and end pixel numbers for those bins with more than one pixel (for the others nend(i)=nbeg(i)-1)
            nend = reshape(cumsum(npix_flush(:)),size(npix_flush)); % end pixel number for each bin for each file
            nbeg = nend-npix_flush+1;                               % start pixel number for each bin for each file
            % Read pixels from input files
            pix_tb=cell(1,nfiles);                                  % buffer for pixel information
            npixels = 0;
            if (log_level>1)
                tr = tic;
            end
            for i=1:nfiles
                if npix_in_files(i)>0
                    try
                        [pix_tb{i},~,ok,mess] = fread_catch(fid(i),[9,npix_in_files(i)],'*float32');
                        npixels = npixels +numel(pix_tb{i});
                        %[pix_buff(:,nbeg(1,i):nend(end,i)),count,ok,mess] =
                    catch   % fixup to account for not reading required number of items (should really go in fread_catch)
                        ok = false;
                        mess = 'Unrecoverable read error after maximum no. tries';
                    end
                    if ~all(ok);
                        if close_input_files; for j=1:nfiles; fclose(fid(j)); end; end;
                        mess = ['Error reading pixel data from ',infiles{i},' : ',mess];
                        return
                    end
                end
            end
            if (log_level>1)
                t_read=toc(tr);
                disp(['   ***time to read sub-cells: ',num2str(t_read),' speed: ',num2str(npixels*4/t_read/(1024*1024)),'MB/sec'])
            end
            
            
            if change_fileno
                for i=1:nfiles
                    pix_block = pix_tb{i};
                    if(numel(pix_block) > 0)
                        if fileno
                            pix_block(5,:)=i;
                        else
                            pix_block(5,:) =pix_block(5,:)+run_label(i); % offset the run index
                        end
                        pix_tb{i} = pix_block;
                    end
                end
            end
            pix_buff = cat(2,pix_tb{:});
            % Write to the output file
            npix_flush=npix_flush'; % transpose so order of elements is succesive files for 1st bin, succesive files for second etc.
            ok=npix_flush>0;        % ranges with at least one pixel
            if sum(ok(:))>0
                nbeg=nbeg'; nbeg=nbeg(ok);  % transpose and use OK to get start of ranges in order of files for a given bin
                nend=nend'; nend=nend(ok);  % similarly for end of range
                
                %                 nranges=cell(1,length(nbeg));
                %                 for i=1:length(nbeg)
                %                     nranges{i}=nbeg(i):nend(i);
                %                 end
                %                 ind=[nranges{:}];           % index into pix_buff of the order in which to write pixels
                blocks_size = nend-nbeg+1;
                all_sizes =[0;cumsum(blocks_size)];
                ind  = zeros(all_sizes(end),1);
                for i=1:length(nbeg)
                    ind((all_sizes(i)+1):all_sizes(i+1))=nbeg(i):nend(i);
                end
                
                pix_buff=pix_buff(:,ind);   % rearrange pix_buff
                
                if (log_level>1)
                    disp(['   ***pix_buff: ',num2str(size(pix_buff))])
                    tw = tic;
                end
                fwrite(fout,pix_buff,'float32');    % write to output file
                if (log_level>1)
                    t_write=toc(tw);
                    block_size = numel(pix_buff)*4/(1024*1024);
                    file_size = file_size+block_size;
                    disp(['   ***timeto flush buffer : ',num2str(t_write),' speed: ',num2str(block_size/t_write),'MB/sec'])
                end
                %                 disp(['  Number of pixels written from buffer: ',num2str(size(pix_buff,2))])
            end
            clear npix_flush npix_in_files nend nbeg ok ind pix_buff  % clear the memory ofbig arrays (esp. pix_buff)
            nbuff_write = nbuff_write + 1;
            if (log_level>1)
                t_total=toc(t_all);
                t_io   = t_write+t_read;
                disp(['   ***IO time to total time ratio: ',num2str(100*t_io/t_total),'%'])
            end
            
        end
        ibin_lastflush = ibin;
        npix_lastflush = npix_cumsum(ibin_lastflush);
        mess_completion(npix_lastflush)
    end
end
if (log_level>1)
    disp(['   ***IO time to total time ratio: ',num2str(100*t_io/t_total),'%'])
    disp(['******Processed: ',num2str(file_size),' MB'])
end

%profile off
%profile viewer
mess_completion
% disp([' single bin write operations: ',num2str(nsinglebin_write)])
% disp(['     buffer write operations: ',num2str(nbuff_write)])

% Close down
if close_input_files; for j=1:nfiles; fclose(fid(j)); end; end;

%================================================================================================
function [npix_section,ibin_end,mess]=get_npix_section(fid,pos_npixstart,ibin_start,ibin_max)
% Fill a structure with sections of the npix arrays for all the input files. The positions of the
% pointers in the input files is left at the positions on entry (the algorithm requires them to be moved, but returns
% them at the end of the operation)
%
%   >> [npix_section,ibin_end,mess]=get_npix_section(fid,pos_npixstart,ibin_start,ibin_max)
%
% Input:
% ------
%   fid             Array of file identifiers for the input sqw files
%   ibin_start      Get section starting with this bin number
%   ibin_max        Maximum number of bins
%
% Output:
% -------
%   npix_section    npix_section{i} is the section npix(ibin_start:ibin_end) for the ith input file
%   ibin_end        Last bin number in the buffer - it is determined either by the maximum size of nbin in the
%                  files (as given by ibin_max), or by the largest permitted size of the buffer
%   mess            Error message: if all OK will be empty, if not OK will contain a message

ibin_buffer_max_size_bytes = 100000000;     % buffer size (in bytes) for holding section of npix arrays

nfiles = length(fid);
ibin_buffer_max_size = floor(ibin_buffer_max_size_bytes/(8*nfiles));    % max. no. of entries in buffer
ibin_buffer_fill = min(ibin_buffer_max_size,ibin_max-ibin_start+1);     % no. of elements of npix to read

% Fill output arguments:
npix_section = cell(nfiles,1);
ibin_end = ibin_start + ibin_buffer_fill - 1;
mess = [];
for i=1:nfiles
    pos_on_input = ftell(fid(i));   % keep the current position
    status=fseek(fid(i),pos_npixstart(i)+8*(ibin_start-1),'bof');    % location of npix for bin number ibin_start (recall written as int64)
    if status<0
        filename = fopen(fid);
        mess = ['Unable to find location of npix data in ',filename];
        return
    end
    [tmp,count,ok,mess] = fread_catch(fid(i),ibin_buffer_fill,'*int64'); if ~all(ok); return; end;
    npix_section{i}=double(tmp);    % all tmp have the same size, so no defragging of stack
    status=fseek(fid(i),pos_on_input,'bof');    % put back in position that had on entry
    if status<0
        filename = fopen(fid);
        mess = ['Unable to return to entry location of pixel data in ',filename];
        return
    end
end
%
function  [mess,infiles] = combine_files_using_mex(fout_name,n_bin,pix_out_position,...
    infiles,npixstart, pixstart,runlabel,change_fileno,fileno)
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
        if fileno
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
    
[out_buf_size,log_level] = get(hor_config,'mem_chunk_size','log_level');

% conversion parameters include:
% n_bin        -- number of bins in the image array
% 1            -- first bin to start copty pixels for
% out_buf_size -- the size of ouput buffer to use for writing pixels
% change_fileno-- if pixel run id should be changed
% fileno       -- if change_fileno is true, how to calculate the new pixel
%                 id -- by providing new id or by adding it to existing.
% num_ticks    -- approximate number of log messages to generate while 
%                 combining files together 
program_param = [n_bin,1,out_buf_size,log_level,change_fileno,fileno,100,512];
try
    combine_sqw(in_params,out_param ,program_param);
    mess = '';
catch ME;
    mess = [ME.identifier,'::',ME.message];    
end

