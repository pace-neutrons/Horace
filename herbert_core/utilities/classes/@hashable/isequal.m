function is  = isequal(varargin)
%ISEQUAL overload of standard isequal method to handle the case
% when one object has hash calculated and another one has not been calculated
% properly.
%

argi = cellfun(@clear_hash_for_hashable,varargin,...
        'UniformOutput',false);
is = builtin('isequal',argi{:});


function ha = clear_hash_for_hashable(ha)
if isa(ha,'hashable')
    if isscalar(ha)
        ha = ha.clear_hash();
    else
        ha = arrayfun(@(x)clear_hash(x),ha);
    end

end