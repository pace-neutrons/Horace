function [iseq, mess] =equal_to_tol_single_(obj1, obj2,opt,varargin)
% Compare single pair of hashable objects
%
% internal procedure used by equal_to_toll method to compare
% single pair of hashable objects from possible array of such objects
%
% Input:
% obj       -- first object to compare
% other_obj -- second object to compare
% opt       -- the structure containing field-names and their
%              values as accepted by generic equal_to_tol
%              procedure or returned by
%              process_inputs_for_eq_to_tol function
%
% Returns:
% iseq      -- logical containing true if objects are equal and
%              false otherwise.
% mess      -- char array empty if iseq == true or containing
%              more information on the reason behind the
%              difference if iseq == false

mess = '';
if obj1.hash_defined && obj2.hash_defined
    % fast comparison. By definition, two hashable objects with the equal
    % hashes are equal
    iseq = isequal(obj1.hash_value,obj2.hash_value);
    if iseq
        return;
    end
end

% compare in more details explaining the reason why it may not be equal and
% where
flds = obj1.hashableFields();
for i=1:numel(flds)
    lopt = opt;
    lopt.name_a = [opt.name_a,'.',flds{i}];
    lopt.name_b = [opt.name_b,'.',flds{i}];

    tmp1 = obj1.(flds{i});
    tmp2 = obj2.(flds{i});
    [iseq,mess] = equal_to_tol (tmp1 , tmp2, lopt,varargin{:});
    if ~iseq
        return;
    end
end
end
