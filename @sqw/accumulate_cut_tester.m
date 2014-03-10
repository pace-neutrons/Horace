function [s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut_tester(sqw,s, e, npix, urange_step_pix, keep_pix,...
    v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax)
	% service routine used in tests only to allow testing private mex/nomex routines without changing working folder

% $Revision: 805 $ ($Date: 2013-11-30 18:38:14 +0000 (Sat, 30 Nov 2013) $)

[s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut(s, e, npix, urange_step_pix, keep_pix,...
    v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, pax);
