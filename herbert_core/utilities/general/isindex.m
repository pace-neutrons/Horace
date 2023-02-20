function ok = isindex(vec)
% Determines whether vec could be used as an array index
% i.e. array is 1-D, and either:
%   logical mask
%   array of positive integer indices
    ok = isvector(vec) && ...
         (islogical(vec) || ...
          (isnumeric(vec) && all(vec > 0) && all(floor(vec) == vec)));
end
