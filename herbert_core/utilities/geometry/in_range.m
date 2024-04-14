function [in,in_details] = in_range(min_max_ranges,coord)
%IN_RANGE identifies if the input coordinates lie within the
%specified data range.
%
% Inputs:
% min_max_range -- [2 x NDim] array, containing min/max ranges to verify
%                  against coordinate vector, where NDim is the number of
%                  dimensions to check
% coord         -- [NDim x N_coord] vector of coordinates to verify against the
%                  limits where N_coord is the number of vectors to verify
% Output:
% in            -- [1 x N_coord] integer array containing 1 if coord are within
%                  the min_max_ranges, 0 if it is on the edge and -1 if it
%                  is outside of the ranges.
% in_details   --  [NDim x N_coord] array of integers, specifying the same
%                  as
%
% Do we need to calculate equality within range?
nDims = size(min_max_ranges,2);
nVectors = size(coord,2);
outside  = coord < min_max_ranges(1,:)' | coord >  min_max_ranges(2,:)';
equal    = coord== min_max_ranges(1,:)' | coord == min_max_ranges(2,:)';


in = ones(1,nVectors);
in(any(outside,1)) = -1;
in(any(equal,1))   = 0;

if nargout > 1
    in_details = ones(nDims,nVectors);
    in_details(outside) = -1;
    in_details(equal)   = 0;
else
    in_details = [];
end
