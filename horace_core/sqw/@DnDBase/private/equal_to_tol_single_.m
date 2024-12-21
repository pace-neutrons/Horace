function [iseq, mess] =equal_to_tol_single_(obj1, obj2,opt,varargin)
% Compare single pair of DnDBase objects
%
% internal procedure used by equal_to_toll method to compare
% single pair of DnDBase objects
% Input:
% obj1      -- first object to compare
% obj1      -- second object to compare
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
ignore_str = opt.ignore_str;
for i=1:numel(flds)
    lopt = opt;
    lopt.name_a = [opt.name_a,'.',flds{i}];
    lopt.name_b = [opt.name_b,'.',flds{i}];

    tmp1 = obj1.(flds{i});
    tmp2 = obj2.(flds{i});
    if ignore_str && istext(tmp1) && istext(tmp2)
        continue;
    end
    if ismember(flds{i},{'s','e'}) % compare signal and error as single values
        % regardless of their actual accuracy. this is what actually matter
        tmp1 = single(tmp1);
        tmp2 = single(tmp2);
    end
    [iseq,mess] = equal_to_tol (tmp1 , tmp2, lopt,varargin{:});
    if ~iseq
        return;
    end
end
end
