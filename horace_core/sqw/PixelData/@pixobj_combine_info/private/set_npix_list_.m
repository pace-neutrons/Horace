function obj = set_npix_list_(obj,val)
% Main setter for list of npix arrays, describing distrinution of pixels
% over bins
% Accepts single npix or cellarry of npix distributions. All heed to have
% the same number of elements.

if iscell(val)
    nbins = numel(val{1});
    eq_nbins = cellfun(@(x)(numel(x)==nbins),val);
    if ~all(eq_nbins)
        error('HORACE:pixobj_combine_info:invalid_argument', ...
            ['All pixels distributions (npix) should contain equal number of bins.\n' ...
            ' There ara %d distributions which does not'],sum(~eq_nbins));
    end
    val_norm = cellfun(@(x)x(:),val,'UniformOutput',false);
    obj.npix_list_ = val_norm(:);

elseif isnumeric(val)
    obj.npix_list_ = {val(:)};
    nbins = numel(val);
end
 obj.nbins_ =  nbins;
if obj.do_check_combo_arg_
    obj = obj.check_combo_arg();
end