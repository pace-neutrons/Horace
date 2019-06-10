function [C, m, n] = genunique_private(Asorted, ix, first, legacy_output)
% Given a sorted array and index to the original, return the output for 'unique'
%
%   >> [bStruct m, n] = uniqueStruct(Asorted)
%   >> [bStruct m, n] = uniqueStruct(Asorted, occurence)
%   >> [bStruct m, n] = uniqueStruct(...,'legacy')
%
% Input:
% ------
%   Asorted     Contains the elements of an original array, A, sorted into
%              ascending order (vector). No check is performed that the
%              array actually is sorted.
%
%   ix          Index of elements in the original unsorted array, A, such
%              that Asorted = A(ix)
%
%   first       If true, the index element in output array m will point to
%              the first occurence of a non-unique element in A
%
%   legacy_output   If present, then the output array m (below) follows the
%                  legacy behaviour (i.e. Matlab 2012b and earlier)
%
% Output:
% -------
%   C           Sorted array of unique elements in Asorted
%
%   m           Index array such that C=A(m)
%
%   n           Index array such that A=C(n)


% Case of empty array - return after setting correct output
if numel(Asorted)==0
    % Note: we exclude size(A)=[0,0] because we allow only vectors
    if legacy_output
        % Legacy orientation is different for empty vector cf non-empty!
        C = reshape(Asorted,0,1);
        m = zeros(0,1);
        n = zeros(0,1);
    else
        C = Asorted;
        m = zeros(0,1);
        n = zeros(0,1);
    end
    return
end

% SPECIAL CASE: if A is not empty, but ix = 1, this is interpreted to mean
% that all elements are equal. We use this slightly dodgy indication so that
% the handling of current and legacy output in this simple situation can be
% dealt with in just the one .m file, making it less likely that
% inconsistencies will come in any future debugging.
if isempty(ix) || numel(ix)==1     % if the input is consistent this must be ix==1
    C = Asorted(1);
    m = 1;
    if legacy_output
        n = ones(size(Asorted));    % vector with the same orientation as A
    else
        n = ones(numel(Asorted),1);
    end
    return
end

% GENERAL CASE:
% Find unique elements
nel=numel(Asorted);
equal_prev=false(nel,1);
for i=2:nel
    if isequaln(Asorted(i-1),Asorted(i))
        equal_prev(i)=true;
    end
end
if ~any(equal_prev)
    C=Asorted;
    m=ix;
    n=(1:numel(m))';
    [~,ind]=sort(ix);
    n=n(ind);
else
    de=diff([equal_prev;0]);
    ibeg=find(de==1);
    iend=find(de==-1);
    indexu=ix;
    for i=1:numel(ibeg)
        if first
            indexu(ibeg(i):iend(i))=min(indexu(ibeg(i):iend(i)));
        else
            indexu(ibeg(i):iend(i))=max(indexu(ibeg(i):iend(i)));
        end
    end
    C=Asorted(~equal_prev);
    m=indexu(~equal_prev);
    n=zeros(size(ix));
    n(~equal_prev)=1:numel(m);
    for i=1:numel(ibeg)
        n(ibeg(i):iend(i))=n(ibeg(i));
    end
    [~,ind]=sort(ix);
    n=n(ind);
end

% Orient vectors to follow convention for Matlab intrinsic function unique
% Simple rules as we are only accepting vector A)

if isrow(Asorted)
    C = C(:)';
else
    C = C(:);
end

if legacy_output
    if isrow(Asorted)
        m = m(:)';
        n = n(:)';
    else
        m = m(:);
        n = n(:);
    end
else
    m = m(:);
    n = n(:);
end
