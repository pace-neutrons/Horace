function hashable_obj_tester(hobj,values,names)
%hashable_obj_tester Generic function which validates correct hashable
%object operations.
%
% Checks if all hashable properties invalidate hash, hash calculations work
% and hash is stored-restored correctly
%
% Inputs:
% hobj  -- instance of hashable object, better with proper values set
% Optional
% values-- cellarray of values to set to hashable object. If present, have
%          to have number of elements equal to number of hashable
%          properties and values of this properties compartible with
%          serializeble, i.e. setting property do not contradict to other
%          properties, validated through check_combo_arg method
% names -- list of the properties to set to check hashable object.
%          If missing, use hashableFields
%
if ~exist('names','var')
    flds = hobj.hashableFields();
else
    flds = names;
end


n_flds = numel(flds);
if ~exist('values','var')
    values = cellfun(@(x)hobj.(x),flds,'UniformOutput',false);
end

if ~hobj.hash_defined
    hobj = hobj.build_hash();
end

for i=1:n_flds
    assertTrue(hobj.hash_defined)
    hobj.(flds{i}) = values{i};
    if hobj.hash_defined
        assertFalse(true, ...
            sprintf('*** Hash remains defined for changed property: %s ',flds{i}));
    end
    hobj = hobj.build_hash();
end

S = hobj.to_struct();
rec_obj= hobj.from_struct(S);

assertTrue(hobj.hash_defined);
assertTrue(hobj == rec_obj)

obj_arr = [hobj,hobj];
S = obj_arr.to_struct();
rec_arr= hobj.from_struct(S);

assertTrue(rec_arr.hash_defined);
assertTrue(obj_arr == rec_arr)