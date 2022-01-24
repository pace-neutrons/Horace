function [sz,nd] = nbins_as_size(obj)
% return bumber of bins in 4D block, e.g.
% 1D object cut with 10 bins cut along en axis will have 1x1x1x10
% sz
sz = zeros(4,1);
nd = numel(obj.p);
psize = cellfun(@(x)(numel(x)-1),obj.p);
sz(obj.pax) = psize(:);
sz(obj.iax) = 1;
sz = sz';