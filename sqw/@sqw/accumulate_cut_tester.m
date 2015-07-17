function [s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut_tester(sqw,s, e, npix, urange_step_pix, keep_pix,...
    v, proj, pax)
	% service routine used in tests only to allow testing private mex/nomex routines without changing working folder

% $Revision$ ($Date$)

[s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut(s, e, npix, urange_step_pix, keep_pix,...
    v,proj, pax);
