function [iseq, mess] =equal_to_tol_single_(obj1, obj2,opt,varargin)
% Compare single pair of serializeble objects
%
% internal procedure used by equal_to_toll method to compare
% single pair of serializable objects
% Input:
% obj       -- first object to compare
% other_obj -- second object to compare
% opt       -- the structure containing fieldnames and their
%              values as accepted by generic equal_to_tol
%              procedure or retruned by
%              process_inputs_for_eq_to_tol function
%
% Returns:
% iseq      -- logical containing true if objects are equal and
%              false otherwise.
% mess      -- char array empty if iseq == true or containing
%              more information on the reason behind the
%              difference if iseq == false
%

flds = obj1.saveableFields();
iseq = true;
mess = '';
for i=1:numel(flds)
    lopt = opt;
    lopt.name_a = [opt.name_a,'.',flds{i}];
    lopt.name_b = [opt.name_b,'.',flds{i}];

    tmp1 = obj1.(flds{i});
    tmp2 = obj2.(flds{i});
    if opt.ignore_str && istext(tmp1) && istext(tmp2)
        continue;
    end
    [iseq,mess] = equal_to_tol (tmp1 , tmp2, lopt);
    if ~iseq
        return;
    end
end
end
