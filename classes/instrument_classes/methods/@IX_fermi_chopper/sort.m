function [fermisort,ix]=sort(fermi)
% Sort an array of objects into ascending order
%
%   >> [objSort,ix]=sort(obj)   % arguments as per intrinsic Matlab

[sortedStruct,ix] = nestedSortStruct(struct(fermi(:)), fieldnames(fermi)');
fermisort=fermi(ix);
