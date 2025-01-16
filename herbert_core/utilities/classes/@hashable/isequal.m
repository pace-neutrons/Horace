function is  = isequal(varargin)
%ISEQUAL overload of standard isequal method to handle the case
% when one object has hash calculated and another one has not been calculated
% properly.
%

argi = cellfun(@clear_hash_for_hashable,varargin,...
        'UniformOutput',false);
is = builtin('isequal',argi{:});


function x = clear_hash_for_hashable(x)
if isa(x,'hashable')
    x = x.clear_hash();
end