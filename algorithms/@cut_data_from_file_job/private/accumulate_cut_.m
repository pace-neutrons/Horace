function [s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut_(s, e, npix, urange_step_pix, keep_pix,...
    v, proj,pax)
%function [s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut (s, e, npix, urange_step_pix, keep_pix,...
%    v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax)
% Accumulate signal into output arrays
%
%   >> [s,e,npix,npix_retain] = accumulate_cut (s, e, npix, v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax, keep_pix)
%
% Input: (* denotes output argument with same name exists - exploits in-place working of Matlab R2007a)
% ------
% * s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
% * e               Array of accumulated variance
% * npix            Array of number of contributing pixels
% * urange_step_pix Actual range of contributing pixels
%   keep_pix        Set to true if wish to retain the information about individual pixels; set to false if not
%   v(9,:)          u1,u2,u3,u4,irun,idet,ien,s,e for each pixel, where ui are coords in projection axes of the pixel data in the file
%
%   urange_step     [2x4] array of the ranges of the data as defined by (i) output proj. axes ranges for
%                  integration axes (or plot axes with one bin), and (ii) step range (0 to no. bins)
%                  for plotaxes (with more than one bin)
%   rot_ustep       Matrix [3x3]     --|  that relate a vector expressed in the
%   trans_bott_left Translation [3x1]--|  frame of the pixel data to no. steps from lower data limit
%                                             r_step(i) = A(i,j)(r(j) - trans(j))
%   ebin            Energy bin width (plays role of rot_ustep for energy axis)
%   trans_elo       Bottom of energy scale (plays role of trans_bott_left for energy axis)
%   pax             Indices of plot axes (with two or more bins) [row vector]
%
% Output:
% -------
%   s               Array of accumulated signal from all contributing pixels (dimensions match the plot axes)
%   e               Array of accumulated variance
%   npix            Array of number of contributing pixels
%   urange_step_pix Actual range of contributing pixels
%   npix_retain     Number of pixels that contribute to the cut
%   ok              If keep_pix==true: v(:,ok) are the pixels that are retained; otherwise =[]
%   ix              If keep_pix==true: column vector of single bin index of each retained pixel; otherwise =[]
%
%
% Note:
% - Aim to take advantage of in-place working within accumulate_cut

% T.G.Perring   19 July 2007

% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

[ignore_nan,ignore_inf,use_mex,n_threads] =...
    config_store.instance().get_value('hor_config','ignore_nan','ignore_inf','use_mex','threads');
ignore_nan=logical(ignore_nan);
ignore_inf=logical(ignore_inf);



if proj.can_mex_cut && use_mex
    [urange_step_pix_recent, ok, ix, s, e, npix, npix_retain,mex_success]=...
        proj.accumulate_cut(v,s,e,npix,pax,ignore_nan,ignore_inf,keep_pix,n_threads);
    if npix_retain>0
        urange_step_pix =[min(urange_step_pix(1,:),urange_step_pix_recent(1,:));max(urange_step_pix(2,:),urange_step_pix_recent(2,:))];  % true range of data
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
    [s, e, npix, urange_step_pix, npix_retain, ok, ix] = accumulate_cut_matlab_(s, e, npix, urange_step_pix, keep_pix,...
        v, proj, pax);
end
