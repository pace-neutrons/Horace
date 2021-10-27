function  struc = struct(obj,varargin)
% convert sqw_dnd object into structure
%
%
prop = indepFields(obj);

for i=1:numel(prop)
    pn = prop{i};
    struc.(pn) = obj.(pn);
end


