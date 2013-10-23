function equivalent=equivalent_mslice_objects(w1,w2)
% Determine if two cut, slice or spe objects are equivalent.
%
%   >> diff_mslice_object(w1,w2)
%
% Checks for equality of fields, but ignores differences in the filename and filepath.
%
% Author: T.G.Perring

if ~isequal(class(w1),class(w2))
    error('The two objects being compared must have the same class')
elseif ~isscalar(w1) || ~isscalar(w2)
    error('Cannot compare arrays of objects')
end

del=objdiff(w1,w2);
if isa(w1,'cut') && ~(isempty(del) || isequal(fieldnames(del),{'CutDir'}) ||...
            isequal(fieldnames(del),{'CutFile'}) || isequal(sort(fieldnames(del)),{'CutDir';'CutFile'}))
    equivalent=false;
elseif isa(w1,'slice') && ~(isempty(del) || isequal(fieldnames(del),{'SliceDir'}) ||...
            isequal(fieldnames(del),{'SliceFile'}) || isequal(sort(fieldnames(del)),{'SliceDir';'SliceFile'}))
    equivalent=false;
elseif isa(w1,'spe') && ~(isempty(del) || isequal(fieldnames(del),{'filepath'}) ||...
            isequal(fieldnames(del),{'filename'}) || isequal(sort(fieldnames(del)),{'filename';'filepath'}))
    equivalent=false;
elseif isa(w1,'cut') || isa(w1,'slice') || isa(w1,'spe')
    equivalent=true;
else
    error('Objects to be checked for equivalence must be cut, slice or spe ojects')
end
