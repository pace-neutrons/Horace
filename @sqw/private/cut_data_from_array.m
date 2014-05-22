function [s, e, npix, urange_step_pix, pix, npix_retain, npix_read] = cut_data_from_array (pix_in, nstart, nend, keep_pix, ...
    urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, nbin)
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
%   npix            Array of number of contributing pixels (if keep_pix==true, otherwise pix=[])
%   urange_step_pix Actual range of contributing pixels
%   pix             if keep_pix==true: contains u1,u2,u3,u4,irun,idet,ien,s,e for each retained pixel; otherwise pix=[]
%   npix_retain     Number of pixels that contribute to the cut
%   npix_read       Number of pixels read from file
%
%
% Note:
% - Redundant input variables in that urange_step(2,pax)=nbin in implementation of 31 July 2007
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   31 July 2007


ndatpix = 9;        % number of pieces of information the pixel info array (see put_sqw_data for more details)
horace_info_level=get(hor_config,'horace_info_level');

% Output arrays for accumulated data
% Note: matlab sillyness when one dimensional: MUST add an outer dimension of unity. For 2D and higher,
% outer dimensions can always be assumed. The problem with 1D is that e.g. zeros([5]) is not the same as zeros([5,1])
% whereas zeros([5,3]) is the same as zeros([5,3,1]).
if isempty(nbin); nbin_as_size=[1,1]; elseif length(nbin)==1; nbin_as_size=[nbin,1]; else nbin_as_size=nbin; end;  % usual Matlab sillyness
s = zeros(nbin_as_size);
e = zeros(nbin_as_size);
npix = zeros(nbin_as_size);
urange_step_pix = [Inf,Inf,Inf,Inf;-Inf,-Inf,-Inf,-Inf];

range = nend-nstart+1;                  % length of the block to be read
npix_read = sum(range(:));              % number of pixels that will be read from file

% Copy data from ranges that may contribute to cut - we assume that if can hold the full data, we will have enough space to hold subset
if horace_info_level>=1, bigtic(1), end
v = zeros(ndatpix,npix_read);
ibeg = cumsum([1;range(1:end-1)]);
iend = cumsum(range);
for i=1:length(range)
    v(:,ibeg(i):iend(i)) = pix_in(:,nstart(i):nend(i));
end
if horace_info_level>=1, t_read = bigtoc(1); end
if horace_info_level>=2
    disp('-----------------------------')
    fprintf(' Cut data started at:  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
end

% Accumulate pixels
if horace_info_level>=1, bigtic(2), end
if horace_info_level>=0, disp(['Have data from ',num2str(npix_read),' pixels - now processing data...']), end
[s, e, npix, urange_step_pix, npix_retain, ok, ix] = accumulate_cut (s, e, npix, urange_step_pix, keep_pix, ...
    v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax);
if horace_info_level>=1, t_accum = bigtoc(2); end

% Sort pixels
if keep_pix
    if horace_info_level>=1, bigtic(3), end
    if horace_info_level>=0, disp(['Sorting pixel information for ',num2str(npix_retain),' pixels']), end
    pix = v(:,ok);          % pixels that are to be retained
    clear v                 % no longer needed - was only a work array - so because it is large, clear before we (possibly) sort pixels
    use_mex=get(hor_config,'use_mex');
    
    if use_mex
        try
            pix = sort_pixels_by_bins(pix,ix,npix);
            clear ix ;  % clear big arrays
        catch
            use_mex=false;
            if horace_info_level>=1
                message=lasterr();
                warning(' Can not sort_pixels_by_bins using c-routines, reason: %s \n using Matlab',message)
            end
        end
    end
    if ~use_mex
        [ix,ind]=sort(ix);  % returns ind as the indexing array into pix that puts the elements of pix in increasing single bin index
        clear ix ;           % clear big arrays so that final output variable pix is not way up the stack
        pix=pix(:,ind);      % reorders pix
    end
    
    if horace_info_level>=1, t_sort = bigtoc(3); end
else
    pix = [];
end

if horace_info_level>=1
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
    if horace_info_level>1
        fprintf('Cut data finished at:  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));
    end
    disp('-----------------------------')
    disp(' ')
end
