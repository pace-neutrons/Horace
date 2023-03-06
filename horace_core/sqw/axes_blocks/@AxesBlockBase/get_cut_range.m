function bin_range = get_cut_range(obj,varargin)
% return binning range of existing data object, so that cut without
% parameters, performed within this range would return the same cut
% as the original object
% 
% Optional:
% -full_range -- if provided, returns 4-element cell array, containing
%                binning ranges and integration ranges along all 4-D axes.
%
% Returns:
%
% bin_range  -- Cellarray of bin ranges in the form [min,step,max] so that
%               cut(bin_range{:}) would return the same cut, as the
%               original cut
% 
[ok,mess,full_range] = parse_char_options(varargin,{'-full_range'});
if ~ok
    error('HORACE:AxesBlockBase:invalid_argument',mess);
end


ndims = numel(obj.pax);
bin_range = cell(ndims,1);
if full_range
    fl_range = cell(4,1);    
end

for i=1:ndims
    bins_centers=0.5.*(obj.p{i}(1:end-1) + obj.p{i}(2:end));
    min_unref=min(bins_centers);
    max_unref=max(bins_centers);
    bin_range{i} =[min_unref,obj.p{i}(2)-obj.p{i}(1),max_unref];
end

if ~full_range
    return;
end
fl_range(obj.pax) = bin_range(:);
for i=1:4-ndims
    fl_range{obj.iax(i)} = obj.iint(:,i)';
end
bin_range = fl_range;