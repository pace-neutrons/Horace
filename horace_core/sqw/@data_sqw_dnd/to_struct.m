function  struc = to_struct(obj,varargin)
% convert sqw_dnd object into structure
%
%   Detailed explanation goes here

prop = properties(obj);
struc = struct();
for i=1:numel(prop)
    pn = prop{i};
    struc.(pn) = obj.(pn);
end


