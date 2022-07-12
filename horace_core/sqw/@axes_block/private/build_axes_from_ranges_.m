function pc = build_axes_from_ranges_(obj)
% build projection axes from internal ranges and the binning
%
% main part of the p accessor
is_pax = obj.nbins_all_dims_ > 1 | ...
    (obj.nbins_all_dims_ == 1 & ~obj.one_nb_is_iax_);
npax = sum(is_pax);
pc = cell(1,npax);
if npax == 0
    return;
end
prange = obj.img_range_(:,is_pax);
nbins  = obj.nbins_all_dims_(is_pax);
for i=1:npax
    if any(isinf(prange(:,i)))
        if sign(prange(1,i)) ~= sign(prange(2,i))
            pc{i} = [prange(1,i),0,prange(2,i)];
        else
            pc{i} = [prange(1,i),prange(2,i)];
        end
    else
        pc{i} = linspace(prange(1,i),prange(2,i),nbins(i)+1);
    end
end