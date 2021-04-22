function [s, e, npix, img_range_step, pix, npix_retain, npix_read] = cut_data_from_file_(fid, nstart, nend, keep_pix, pix_tmpfile_ok,...
    proj,pax, nbin)
%function [s, e, npix, img_range_step, pix, npix_retain, npix_read] = cut_data_from_file (fid, nstart, nend, keep_pix, pix_tmpfile_ok,...
%    img_range_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin)
% Accumulates pixels into bins defined by cut parameters
%
%   >> [s, e, npix, npix_retain] = cut_data (fid, nstart, nend, img_range_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin, keep_pix)
%
% Input:
% ------
%   fid             File identifier, with current position in the file being the start of the array of pixel information
%   nstart          Column vector of read start locations in file
%   nend            Column vector of read end locations in file
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   pix_tmpfile_ok  if keep_pix=false, ignore
%                   if keep_pix=true, set buffering option:
%                       pix_tmpfile_ok = false: Require pix is a PixelData object
%                       pix_tmpfile_ok = true:  Buffering of pixel info to temporary files if pixels exceed a threshold
%                                              In this case, output argument pix contains details of temporary files (see below)
%   img_range_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
%   pax             Indices of plot axes (with two or more bins) [row vector]
%   nbin            Number of bins along the projection axes with two or more bins [row vector]
%
% Output:
% -------
%   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
%   e               Array of accumulated variance
%   npix            Array of number of contributing pixels (if keep_pix==true, otherwise pix=[])
%   img_range_step Actual range of contributing pixels
%   pix             if keep_pix=false, pix=[];
%                   if keep_pix==true, then contents depend on value of pix_tmpfile_ok:
%                       pix_tmpfile_ok = false: contains a PixelData object
%                       pix_tmpfile_ok = true: structure with fields
%                           pix.tmpfiles        cell array of filename(s) containing npix and pix
%                           pix.pos_npixstart   array with position(s) from start of file(s) of array npix
%                           pix.pos_pixstart    array with position(s) from start of file(s) of array npix
%   npix_retain     Number of pixels that contribute to the cut
%   npix_read       Number of pixels read from file
%
%
% Note:
% - Redundant input variables in that img_range_step(2,pax)=nbin in implementation of 19 July 2007
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   19 July 2007 (based on earlier prototype TGP code)
%

% Buffer sizes
ndatpix = 9;        % number of pieces of information the pixel info array (see put_sqw_data for more details)
%vmax is maximum length of buffer array in which to accumulate points from the input file
hor_log_level=config_store.instance().get_value('herbert_config','log_level');
buf_size=config_store.instance().get_value('hor_config','mem_chunk_size');


% Output arrays for accumulated data
% Note: Matlab silliness when one dimensional: MUST add an outer dimension of unity. For 2D and higher,
% outer dimensions can always be assumed. The problem with 1D is that e.g. zeros([5]) is not the same as zeros([5,1])
% whereas zeros([5,3]) is the same as zeros([5,3,1]).
if isempty(nbin) % usual Matlab sillyness
    nbin_as_size=[1,1];
elseif length(nbin)==1
    nbin_as_size=[nbin,1];
else
    nbin_as_size=nbin;
end
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
img_range_step = PixelData.EMPTY_RANGE_;

% *** T.G.Perring 26 Sep 2018:*********************
% Catch case of nstart and nend being empty - this corresponds to no data in the boxes that
% interect with the cut. As of 26 Sep 2018 the rest of the code does not work if nstart is empty
% but even if it did, catching this case here avoids a lot of unecessary working later on
if isempty(nstart)
    pix = PixelData();
    npix_retain = 0;
    npix_read = 0;
    return
end
% ***********************************************

npix_retain = 0;
%------------------------------------------------
pmax = 2*buf_size;                       % maximum length of array in which to buffer retained pixels (pmax>=vmax)

noffset = nstart-[0;nend(1:end-1)]-1;   % offset from end of one block to the start of the next
range = nend-nstart+1;                  % length of the block to be read
npix_read = sum(range(:));              % number of pixels that will be read from file
%
% find the data blocks to fit buffer size
[noffset,range,block_ind_from,block_ind_to] = find_blocks(noffset,range,buf_size);
%
% number of blocks to be read from hdd -- used in the progress indicator.
nsteps=numel(block_ind_from);
if nsteps == 1 % one block should be written to target file directly
    pix_tmpfile_ok = false;
end
%
%
% Buffer array for retained pixels
if keep_pix
    if pix_tmpfile_ok
        % pix is pix_combine info class
        pix = init_pix_combine_info(nsteps,numel(s));
    else
        pix = PixelData();   % changed 17/11/08 from pix = [];
    end
else
    pix = PixelData();   % pix is a return argument, so must give it a value
end

t_read  = [0,0];
t_accum = [0,0];
t_sort  = [0,0];

if hor_log_level>=2
    disp('-----------------------------')
    fprintf(' Cut data from file started at:  %4d;%02d;%02d|%02d;%02d;%02d\n',fix(clock));
end
% -------------------------------------------------------
% check if this program runs in worker under MPI framework
mpi_obj        =  MPI_State.instance();
is_deployed_mpi = mpi_obj.is_deployed;
% -------------------------------------------------------
%
if ~pix_tmpfile_ok && keep_pix
    pix_retained = cell(1,nsteps);
    pix_retained(1, :) = {PixelData()};
    pix_ix_retained=cell(1,nsteps);
else
    pix_retained  = {};
    pix_ix_retained = {};
end

n_blocks = 0;
if hor_log_level>=1, bigtic(1), end
%

try
    for i=1:nsteps
        if hor_log_level>=1;    bigtic(1);    end
        % -- read
        pix_data=PixelData(read_data_block_(fid,noffset,range,block_ind_from(i),block_ind_to(i),ndatpix));
        %
        if hor_log_level>=1;  t_read = t_read + bigtoc(1); bigtic(2);   end
        if hor_log_level>=0
            fprintf('Step %3d of %4d; Have read data for %d pixels -- now processing data...',i,nsteps,pix_data.num_pixels);
        end
        %
        % -- cut
        [s, e, npix, img_range_step, del_npix_retain, ok, ix_add] = ...
            cut_data_from_file_job.accumulate_cut (s, e, npix, img_range_step, keep_pix, ...
            pix_data, proj, pax);
        if hor_log_level>=0; fprintf(' ----->  retained  %d pixels\n',del_npix_retain); end
        if hor_log_level>=1; t_accum = t_accum + bigtoc(2); end
        %
        % -- retain
        npix_retain = npix_retain + del_npix_retain;
        if keep_pix && del_npix_retain > 0
            if hor_log_level>=1, bigtic(3), end
            if pix_tmpfile_ok
                % pix now not an array but pix_combine_info class
                pix = accumulate_pix_to_file_(pix,false,pix_data,ok,ix_add,npix,pmax,del_npix_retain);
            else
                n_blocks=n_blocks+1;
                pix_retained{n_blocks} = pix_data.get_pixels(ok);    % accumulate pixels into buffer array
                pix_ix_retained{n_blocks} = ix_add;
            end
            if hor_log_level>=1, t_sort = t_sort + bigtoc(3); end
        end
        % -------------

        if hor_log_level>=1, bigtic(1), end
        % if program runs as mpi worker, check if it has been
        % cancelled and throw if it was.
        if is_deployed_mpi
            mpi_obj.check_cancellation();
        end
    end
catch ME
    if pix_tmpfile_ok
        accumulate_pix_to_file_(pix,true,pix_data,ok,ix_add,npix,pmax,del_npix_retain)
        for j=1:pix.nfiles
            if exist(pix.infiles{j},'file')==2
                delete(pix.infiles{j});
            end
        end
    end
    rethrow(ME);
end
%
if hor_log_level>=1, t_read = t_read + bigtoc(1); end
%---------------------------------------------------------------------------------
% Finish -- glue up all arrays with pixels into final pixel arrays
%---------------------------------------------------------------------------------
if ~isempty(pix_retained) || pix_tmpfile_ok  % prepare the output pix array
    % or file combine info
    if hor_log_level>=1, bigtic(3), end

    clear pix_data ok ix_add; % clear big arrays
    if pix_tmpfile_ok % this time pix is pix_combine_info class. del_npix_retain not used
        pix_data = PixelData(); ok=[]; ix_add=[];
        pix = accumulate_pix_to_file_(pix,true,pix_data,ok,ix_add,npix,pmax,0);
    else
        if ~isempty(pix_retained)
            pix = sort_pix(pix_retained,pix_ix_retained,npix);
        end
    end
    if hor_log_level>=1, t_sort = t_sort + bigtoc(3); end

end


if hor_log_level>=1
    disp('-----------------------------')
    disp('Inside cut_data:')
    disp ('  Timings for reading:')
    disp(['        Elapsed time is ',num2str(t_read(1)),' seconds'])
    disp(['            CPU time is ',num2str(t_read(2)),' seconds'])
    disp(' ')
    disp ('  Timings in accumulate_cut:')
    disp(['        Elapsed time is ',num2str(t_accum(1)),' seconds'])
    disp(['            CPU time is ',num2str(t_accum(2)),' seconds'])
    if keep_pix
        disp(' ')
        disp ('  Timings for handling pixel information')
        disp(['        Elapsed time is ',num2str(t_sort(1)),' seconds'])
        disp(['            CPU time is ',num2str(t_sort(2)),' seconds'])
    end
    if hor_log_level>=2
        disp('-----------------------------')
        fprintf(' Cut data from file finished at:  %4d;%02d;%02d|%02d;%02d;%02d\n',fix(clock));
    end

    disp('-----------------------------')
    disp(' ')
end

end



function [noffset,img_range_step,block_ind_from,block_ind_to] = find_blocks(noffset,img_range_step,buf_size)
% find buffers blocks and data ranges to read input pixels in blocks,
% approximately equal to the buffer sizes
%
%
if any(img_range_step>2*buf_size) % split big ranges into parts to fit buffer.
    [cell_range,cell_offcet] = arrayfun(@(rg,offs)split_ranges(rg,offs,buf_size),img_range_step,noffset,'UniformOutput',false);
    img_range_step = [cell_range{:}];
    img_range_step = cell2mat(img_range_step);
    noffset   = [cell_offcet{:}];
    noffset   = cell2mat(noffset);
end
tot_pix = cumsum(img_range_step);
nblocks = floor(tot_pix(end)/buf_size)+1;
block_ind_from = ones(1,nblocks);
block_ind_to   = zeros(1,nblocks);
run_sum = buf_size;
last_block_num = 0;
for i=1:nblocks
    ind = find(tot_pix>=run_sum,1);
    if isempty(ind)
        break;
    end
    last_block_num = i;
    block_ind_to(i) = ind;
    if i>1
        block_ind_from(i) = block_ind_to(i-1)+1;
    end

    run_sum = tot_pix(ind)+buf_size;
end
%
if last_block_num < nblocks
    last_block_num = last_block_num + 1;
    if last_block_num>1
        block_ind_from(last_block_num) = block_ind_to(last_block_num-1)+1;
    else
        block_ind_from(1) = 1;
    end
    block_ind_to(last_block_num) = numel(tot_pix);
    if last_block_num<nblocks
        block_ind_from = block_ind_from(1:last_block_num);
        block_ind_to   = block_ind_to(1:last_block_num);
    end
end

end
%
%--------------------
function [cell_rg,cell_off] = split_ranges(range,offset,buf_size)
% split ranges bigger than buf size into approximately buf-size chunks.
if range<2*buf_size
    cell_rg = {range};
    cell_off = {offset};
    return;
end
%
n_cells = floor(range/buf_size)+1;
cell_rg = cell(1,n_cells);
cell_off = cell(1,n_cells);
cell_rg{1} = buf_size;
cell_off{1}= offset;
for i=2:n_cells
    t_range = buf_size;
    shift = buf_size*(i-1);
    if shift+t_range > range; t_range = range-shift; end
    if t_range > 0
        cell_rg{i} = t_range;
    end
    cell_off{i} = 0;
end


end

function pci = init_pix_combine_info(nfiles,nbins)
% define fmp files to store in working directory.

wk_dir = config_store.instance().get_value('parallel_config','working_directory');

tmpfiles = cell(1,nfiles);
tmpfiles = cellfun(@(x)fullfile(wk_dir,['horace_subcut_',rand_digit_string(16),'.tmp']),tmpfiles,'UniformOutput',false);
pci = pix_combine_info(tmpfiles,nbins);
end
