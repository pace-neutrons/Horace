function [s, e, npix, img_range_step, npix_retain,ok, ix] = accumulate_cut_(s, e, npix,img_range_step, keep_pix,...
    v,proj,pax,keep_precision)
%function [s, e, npix, img_range_step, npix_retain,ok, ix] = accumulate_cut (s, e, npix, img_range_step, keep_pix,...
%    v, img_range_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax)
% Accumulate signal into output arrays
%
%   >> [s,e,npix,npix_retain] = accumulate_cut (s, e, npix, v, img_range_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, keep_pix)
%
% Input: (* denotes output argument with same name exists - exploits in-place working of Matlab R2007a)
% ------
% * s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
% * e               Array of accumulated variance
% * npix            Array of number of contributing pixels
% * img_range_step  Actual range of contributing pixels in the units of the
%                   pixel binning
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   v               PixelData object
%
%   img_range_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
%   pax             Indices of plot axes (with two or more bins) [row vector]
%   keep_precision  if true, do not convert pixels in the double but keep
%                   their precision the same as input pixels
%
% Output:
% -------
%   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
%   e               Array of accumulated variance
%   npix            Array of number of contributing pixels
%   img_range_step Actual range of contributing pixels
%   npix_retain     Number of pixels that contribute to the cut
%   ok              If keep_pix==true: v(:,ok) are the pixels that are retained; otherwise =[]
%   ix              If keep_pix==true: column vector of single bin index of each retained pixel; otherwise =[]
%
%
% Note:
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   19 July 2007


[ignore_nan,ignore_inf,use_mex,n_threads] =...
    config_store.instance().get_value('hor_config','ignore_nan','ignore_inf','use_mex','threads');
ignore_nan=logical(ignore_nan);
ignore_inf=logical(ignore_inf);

% Temporary and ineffective solution to keep pixels double all through the
% Horace. TODO: redefine pixels as single and propagate it through all Horace
if isa(v.data,'single') && ~keep_precision
    v.data = double(v.data);
end



if proj.can_mex_cut && use_mex
    [img_range_step_recent, ok, ix, s, e, npix, npix_retain,mex_success]=...
        proj.accumulate_cut(v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads);
    if npix_retain>0
        img_range_step =[min(img_range_step(1,:),img_range_step_recent(1,:));max(img_range_step(2,:),img_range_step_recent(2,:))];  % true range of data
    else
        ix=ones(0,1); % to be consistent with matlab
    end
    if mex_success
        return
    else
        use_mex = false;
    end
else
    use_mex = false;
end

if ~use_mex
    [s, e, npix, img_range_step, npix_retain, ok, ix] = accumulate_cut_matlab_(s, e, npix, img_range_step, keep_pix,...
        v, proj, pax);
end

