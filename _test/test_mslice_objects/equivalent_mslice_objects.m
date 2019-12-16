function equivalent=equivalent_mslice_objects(w1,w2,max_err)
% Determine if two cut, slice or spe objects are equivalent.
%
%   >> diff_mslice_object(w1,w2)
%   >> diff_mslice_object(w1,w2,err)
%
% Checks for equality of fields, but ignores differences in the filename and filepath.
%
% Author: T.G.Perring
if ~exist('max_err','var')
    max_err = 0;
end

if ~isequal(class(w1),class(w2))
    error('The two objects being compared must have the same class')
elseif ~isscalar(w1) || ~isscalar(w2)
    error('Cannot compare arrays of objects')
end

del=objdiff(w1,w2);

if isa(w1,'cut')
    ignore_fields = {'CutDir','CutFile'};
    equivalent= check_equivalence(del,ignore_fields,max_err);
elseif isa(w1,'slice')
    ignore_fields = {'SliceDir','SliceFile'};
    equivalent= check_equivalence(del,ignore_fields,max_err);
elseif isa(w1,'spe')
    ignore_fields = {'filename','filepath'};
    equivalent= check_equivalence(del,ignore_fields,max_err);
elseif isa(w1,'cut') || isa(w1,'slice') || isa(w1,'spe')
    equivalent=true;
else
    error('Objects to be checked for equivalence must be cut, slice or spe ojects')
end

function equivalent= check_equivalence(del,ignore_fields,max_err)
%
fnam = fieldnames(del);
is_ignored = ismember(fnam,ignore_fields);
if all(is_ignored)
    equivalent = true;
    return;
else
    if max_err>0
        fnam = fnam(~is_ignored);
        equivalent = check_non_ignored_dif(del,fnam,max_err);
    else
        equivalent=false;
    end
end


function equivalent = check_non_ignored_dif(del,non_ignored,err)
%
for i=1:numel(non_ignored)
    dif_data = del.(non_ignored{i});
    diff = max(abs(dif_data{1}-dif_data{2}));
    if any(diff>err)
        equivalent = false;
        return;
    else
        equivalent = true;
    end
end
