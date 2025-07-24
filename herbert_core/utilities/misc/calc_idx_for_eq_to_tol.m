function eq_idx = calc_idx_for_eq_to_tol(data,tolerance)
%CALC_IDX_FOR_EQ_TO_TOL found indices of equal to tolerance 
% input cellarray elements
%
% Inputs:
% data      -- cellarray containing values or arrays of values to compare
%              with each other.
% tolerance -- 2 element array containing absolute and relative limits
%              acceptable to assume elements equal. If the difference
%              between two elements of data is smaller then
%              absolute or relative difference between these elements and the
%              arrays have the same number of elements the data elements are
%              considered equal and their indices get stored in eq_idx
%              cellarray.
%
% Returns:
% eq_idx  --  cellarray of arrays of indices for unique data.
%             If all data are the same,
%             this cellarray will contain single cell and this cell contains
%             all data indices.
%             I.e. if data hold 10 equal elements (e.g. A1):
%             eq_idx == {1:10}.
%             If data contain two different values, first five A1 and
%             second five - A2:
%             eq_idx == {1:5,6:10}
%             All different data elements will return cellarray:
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
        same = calc_difference(data{i},data{j},tolerance);
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
% 
% Similar to checks provided in equal_to_tol, but removed all fluff for speed
% and efficiency.

same = true;
if numel(efix1) ~= numel(efix2)
    same = false;
    return
end
abserr = abs(efix1-efix2);
if all(abserr<Diff(1))
    return
end
relerr = 0.5*max(abserr./(abs(efix1)+abs(efix2)));
if any(relerr>Diff(2))
    same = false;
end
end

