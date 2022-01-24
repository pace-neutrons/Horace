function [sz,nd] = nbins_as_size(obj)
% return bumber of bins in 4D block, e.g.
% 1D object cut with 10 bins cut along en axis will have 1x1x1x10
% sz
sz = zeros(4,1);
nd = numel(obj.p);
sz(obj.pax) = numel(obj.p{:})-1;
sz(obj.iax) = 1;
sz = sz';