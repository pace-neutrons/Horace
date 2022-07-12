function is = is_pax_(obj)
% returns 4-D boolean, with true where projection axis is located.
is = obj.nbins_all_dims_ > 1 | ...
    (obj.nbins_all_dims_ == 1 & ~obj.one_nb_is_iax_);