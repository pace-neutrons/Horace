function [modsort,ix]=sort(moderator)
% Sort an array of objects into ascending order
%
%   >> [objSort,ix]=sort(obj)   % arguments as per intrinsic Matlab
%
% The method uses nestedSortStruct, padding fields with numeric arrays to have the
% same number of elements and treating them as scalars.

aStruct=struct_special(moderator);
[sortedStruct,ix] = nestedSortStruct(aStruct, fieldnames(aStruct)');
modsort=moderator(ix);
