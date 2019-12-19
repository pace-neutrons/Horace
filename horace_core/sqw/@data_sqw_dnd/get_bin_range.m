function bin_range = get_bin_range(obj)
% Method returns binning range of the data  
%
% (if one cuts data withn the range specified, the result would be
% equivalent to original object)
ndims = numel(obj.pax);
bin_range = cell(ndims,1);

for i=1:ndims
    bins_centers=0.5.*(obj.p{i}(1:end-1) + obj.p{i}(2:end));
    min_unref=min(bins_centers)+eps;%add small amount to avoid rounding error
    max_unref=max(bins_centers)-eps;
    bin_range{i} =[min_unref,obj.p{i}(2)-obj.p{i}(1),max_unref];
end






