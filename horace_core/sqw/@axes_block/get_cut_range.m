function bin_range = get_cut_range(obj)
% return binning range of existing data object, so that cut without
% parameters, performed within this range would return the same cut
% as the original object

ndims = numel(obj.pax);
bin_range = cell(ndims,1);

for i=1:ndims
    bins_centers=0.5.*(obj.p{i}(1:end-1) + obj.p{i}(2:end));
    min_unref=min(bins_centers);
    max_unref=max(bins_centers);
    bin_range{i} =[min_unref,obj.p{i}(2)-obj.p{i}(1),max_unref];
end
