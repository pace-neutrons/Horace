function pbin = make_const_bin_boundaries_descr(p)
% Make a constant bin boundaries descriptor from the bin boundaries.
% 
% The function is the opposite to make_const_bin_boundaries, written with
% intention for the pair of 
% >>bb= make_const_bin_boundaries(input)
% >>descr = make_const_bin_boundaries_descr(bb) produce consistent results
% e.g. 
% (input == descr) is true;
% Usage:
%
%   >> pbin = make_const_bin_boundaries_descr_(p)
%
% Input:
% ------
%   p       Bin boundaries, assumed constant spacing
%
% Output:
% -------
%   pbin   Bin boundary descriptor [pbeg, pstep, pend] where
%          pbeg in the first bin centre, pstep is the bin width, and
%          pend is the last bin centre.
%
% *** Really this should be made to guarantee consistency in all edge cases with 
% make_const_bin_boundaries. Have had rounding error probelms in the past
% and want to know that if p was generated from a descriptor that exactly the
% same descriptor is recovered.

step = (p(end)-p(1))/(numel(p)-1);
pbeg = p(1)+step/2;
pend = p(end)-step/2;

pbin = [pbeg,step,pend];
