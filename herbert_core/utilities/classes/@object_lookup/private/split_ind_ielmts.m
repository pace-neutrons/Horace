function [ind_eval, iel, ix, neval, nbeg, nend] = split_ind_ielmts (ind, ielmts, ...
    israndfunc, issplit)
% Determine which values of the indices in ind for which to evaluate the 
% function, together with the number of evaluations for each value and (if
% present) the corresponding values of internal indices.
%
% Input:
% ------
%   ind         Indices of the objects in an object array for which the function
%              is to be evaluated or from which random samples to be pulled
%
%   ielmts      If not empty, an array the same size as input argument ind that
%              gives the index of elements within the object identified by
%              ind.
%               If empty, then treated as not present
%
%   israndfunc  False: if the function is deterministic (i.e. successive calls
%              with the same input arguments will always produce the same
%              output)
%               True: if the function be evaluated is required to return random
%              samples (i.e. succesive calls with the same input arguments will
%              return different results because there is a random sampling
%              aspect to the evaluation)
%
%   issplit     True if one or more function input arguments are to be split
%
% Output:
% -------
%   ind_eval    Values of ind for which the function is to be evaluated or from
%              which random samples to be pulled. Column vector with length
%              equal to numel(ind) or the number of unique values of ind depending on the
%              presence or not of ielmts, and the values of israndfunc and
%              issplit
%
%   iel         Internal elements for which the function evaluations are to be
%              performed
%               - iel is empty if ielmts is empty (i.e. treated as not present)
%               - iel is column vector length numel(ind) if ielmts is present,
%                 in which case iel(nbeg(i):nend(i)) are the internal elements
%                 for which the function is to be evalued for object with index
%                 ind_eval(i). Column vector length numel(ielmts)
%
%   ix          Array to recover original ordering of ind, and ielmts if present.
%               ix==[] if no reordering is necessary
%
%   neval       Number of function evaluations that will be performed for each
%              value of ind_eval. Column vector length numel(ind_eval)
%
%   nbeg        If the function evaluations are performed in the order
%              ind_eval(i) for nel(i) times, i=1,2,3,... then nbeg(i) is the
%              start position in the list of evaluations for ind_eval(i). Column
%              array length numel(ind_eval)
%
%   nend        Similarly, the end position in the list of evaluations for 
%              ind_eval(i). Column vector length numel(ind_eval)

present_ielmts = ~isempty(ielmts);

if ~israndfunc && ~present_ielmts && issplit
    % Is deterministic function evaluation where because ielmts is not present
    % and one or more arguments are to be split, the function needs to be
    % evaluated for every element of ind. There is no need to sort ind to
    % identify and collect unique values as there is no optimisation that is
    % possible in the call tothe function to be evaluated.
    ind_eval = ind(:);
    iel = [];
    ix = [];
    nend = (1:numel(ind))';
    nbeg = (1:numel(ind))';
    neval = ones(numel(ind),1);
else
    % Sort ind and create an index array that relates back to the
    % original ordering. Additionally, if ielmts exists, turn it into a column
    % and reorder to match sorting of ind if it was sorted.
    if issorted(ind(:)) % case that the array is already sorted
        B = ind(:);
        ix = [];    % empty will indicate that no reordering is needed later
        if present_ielmts
            iel = ielmts(:);
        else
            iel = [];
        end
    else
        [B, ix] = sort(ind(:));
        if present_ielmts
            iel = reshape (ielmts(ix), [], 1);  % reorder and make a column vector
        else
            iel = [];
        end
    end
    nend = [find(diff(B)); numel(B)];
    nbeg = 1 + [0;nend(1:end-1)];
    neval = nend - nbeg + 1;
    ind_eval = B(nbeg);     % the unique element index numbers
end
