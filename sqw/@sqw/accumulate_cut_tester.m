function [s, e, npix, urange_step_pix, npix_retain,ok, ix] = accumulate_cut_tester(sqw,urange_step_pix, keep_pix,proj, pax)
	% service routine used in tests only to allow testing private mex/nomex routines without changing working folder

% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
data = sqw.data;
[s, e, npix, urange_step_pix, npix_retain,ok, ix] = cut_data_from_file_job.accumulate_cut(data.s, data.e, data.npix, urange_step_pix, keep_pix,...
    data.pix,proj, pax);
