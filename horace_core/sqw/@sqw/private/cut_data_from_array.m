function [s, e, npix, img_range_step, pix, npix_retain, npix_read] = cut_data_from_array (pix_in, nstart, nend, keep_pix, ...
    proj, pax, nbin)

%function [s, e, npix, img_range_step, pix, npix_retain, npix_read] = cut_data_from_array (pix_in, nstart, nend, keep_pix, ...
%    urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin)
% Accumulates pixels into bins defined by cut parameters
%
%   >> [s, e, npix, npix_retain] = cut_data (pix_in, nstart, nend, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin, keep_pix)
%
% Input:
%   pix_in          Input array of pixel information
%   nstart          Column vector of read start locations in file
%   nend            Column vector of read end locations in file
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   urange_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
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
%   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
%   e               Array of accumulated variance
%   npix            Array of number of contributing pixels (if keep_pix==true, otherwise pix.num_pixels = 0)
%   img_range_step Actual range of contributing pixels
%   pix             if keep_pix==true: contains full PixelData object; otherwise an empty PixelData object
%   npix_retain     Number of pixels that contribute to the cut
%   npix_read       Number of pixels read from file
%
%
% Note:
% - Redundant input variables in that urange_step(2,pax)=nbin in implementation of 31 July 2007
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   31 July 2007
%
%

hor_log_level=config_store.instance().get_value('herbert_config','log_level');

% Output arrays for accumulated data
% Note: Matlab silliness when one dimensional: MUST add an outer dimension of unity. For 2D and higher,
% outer dimensions can always be assumed. The problem with 1D is that e.g. zeros([5]) is not the same as zeros([5,1])
% whereas zeros([5,3]) is the same as zeros([5,3,1]).
if isempty(nbin); nbin_as_size=[1,1]; elseif length(nbin)==1; nbin_as_size=[nbin,1]; else nbin_as_size=nbin; end  % usual Matlab sillyness
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
img_range_step = PixelData.EMPTY_RANGE_;

% *** T.G.Perring 5 Sep 2018:*********************
% Catch case of nstart and nend being empty - this corresponds to no data in the boxes that
% intersect with the cut. As of 26 Sep 2018 the rest of the code works even if nstart is empty
% but catching this case here avoids a lot of unnecessary working later on
if isempty(nstart)
    pix = PixelData();
    npix_retain = 0;
    npix_read = 0;
    return
end
% ***********************************************

range = nend-nstart+1;                  % length of the block to be read
npix_read = sum(range(:));              % number of pixels that will be read from file

% Copy data from ranges that may contribute to cut - we assume that if can hold the full data, we will have enough space to hold subset
if hor_log_level>=1, bigtic(1), end
cut_pix_data = PixelData(npix_read);
ibeg = cumsum([1;range(1:end-1)]);
iend = cumsum(range);
for i=1:length(range)
    cut_pix_data.data(:,ibeg(i):iend(i)) = pix_in.get_pixels(nstart(i):nend(i)).data;
end
if hor_log_level>=1, t_read = bigtoc(1); end
if hor_log_level>=2
    disp('-----------------------------')
    fprintf(' Cut data started at:  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
end

% Accumulate pixels
if hor_log_level>=1, bigtic(2), end
if hor_log_level>=0, disp(['Have data from ',num2str(npix_read),' pixels - now processing data...']), end
[s, e, npix, img_range_step, npix_retain, ok, ix] = ...
    cut_data_from_file_job.accumulate_cut(s, e, npix, img_range_step, keep_pix, ...
    cut_pix_data, proj, pax);
if hor_log_level>=1, t_accum = bigtoc(2); end

% Sort pixels
if keep_pix
    if hor_log_level>=1, bigtic(3), end
    if hor_log_level>=0, disp(['Sorting pixel information for ',num2str(npix_retain),' pixels']), end
    pix = cut_pix_data.get_pixels(ok);          % pixels that are to be retained
    clear cut_pix_data                 % no longer needed - was only a work array - so because it is large, clear before we (possibly) sort pixels

    pix = sort_pix(pix,ix,npix);

    if hor_log_level>=1, t_sort = bigtoc(3); end
else
    pix = PixelData();
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
    if hor_log_level>1
        fprintf('Cut data finished at:  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
    end
    disp('-----------------------------')
    disp(' ')
end

