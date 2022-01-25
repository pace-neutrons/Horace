function pc = build_axes_from_ranges_(obj)
% build projection axes from internal ranges and binning
%
is_pax = obj.nbin_all_dim_ > 1;
npax = sum(is_pax);
pc = cell(1,npax);
if npax == 0
    return;
end
prange = obj.img_range_(:,is_pax);
nbins  = obj.nbin_all_dim_(is_pax);
for i=1:npax
    step = (prange(2,i)-prange(1,i))/nbins(i);
    pc{i} = linspace(prange(1,i)-0.5*step,prange(2,i)+0.5*step,nbins(i)+1);
end