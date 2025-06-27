function eq_idx = calc_eq_indices(data,error)
%CALC_EQ_INDICES Calculate indices of equal input cellarray elements
%
% Inputs:
% data    -- cellarray containing arrays of data
% error   -- 2 element array containing absolute and relative limits
%            acceptable to assume the object same. If the difference
%            between two elemens of data is smaller then
%            absolute or relative error between these elements and the arrays
%            have the same number of members the data elements are
%            considered equal and their indices get stored in eq_idx
%            cellarray.
%
% Returns:
% eq_idx  --  cellarry of arrays of indices for unique data.
%             If all data are the same,
%             this cellarray will contain single cell and this cell contains
%             all data indices.
%             I.e. if there are 10 data elements:
%             eq_idx == {1:10}.
%             If eq_idx contain two different values, first five A1 and
%             second five - A2:
%             eq_idx == {1:5,6:10}
%             All different data will return cellarray:
%             eq_idx = {1,2,3,...9,10};

n_elements = numel(data);
eq_idx  = cell(1,n_elements);
iseq    = false(1,n_elements);
for i = 1:n_elements
    if iseq(i) % is already equal to some previous value
        continue;
    end
    ic = 1;
    eq_bunch            = zeros(1,n_elements-i+1);
    eq_bunch(ic)        = i;
    for j=i+1:n_elements
        same = calc_difference(data{i},data{j},error);
        if same
            ic = ic+1;
            eq_bunch(ic) = j;
            iseq(j) = true;
        end
    end
    eq_idx{i} = eq_bunch(eq_bunch~=0);
end
eq_idx = eq_idx(~iseq);
end

function same = calc_difference(efix1,efix2,Diff)
% function calculate absolute and relative difference between two values
% and return true if absolute or relative difference is smaller than input
% Diff. Diff contains 2 elements, 1-st defines absolute and second --
% values of relative difference.

same = true;
if numel(efix1) ~= numel(efix2)
    same = false;
    return
end
abserr = abs(efix1-efix2);
if all(abserr<Diff(1))
    return
end
relerr = 0.5*max(abserr./(efix1+efix2));
if any(relerr>Diff(2))
    same = false;
end
end

