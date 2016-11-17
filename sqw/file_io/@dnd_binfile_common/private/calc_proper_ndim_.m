function [dim,ndim] = calc_proper_ndim_(dnd_data)
% calculate correct number of dimensions of a dnd data block
%
%
p = dnd_data.p;
if isempty(p)
    ndim = 0;
    dim  = [];
else
    ndim = numel(p);
    dim  = cellfun(@(x)(numel(x)-1),p,'UniformOutput',true);
end
