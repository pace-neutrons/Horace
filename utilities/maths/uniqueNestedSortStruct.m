function [bStruct, m, n] = uniqueNestedSortStruct(aStruct, occurence)
% Equivalent to intrinsic Matlab unique but here for structures
%
%   >> [bStruct m, n] = uniqueNestedSortStruct(aStruct, occurence)
%
% Input:
% ------
%   aStruct     Structure to be sorted. Fields must be character strings or
%              numeric or logical scalars. The sort is done in nested fashion
%
%   occurence   Character string 'last' [default] or 'first'; indicates if the index
%              element in output array m points to first or last occurence of
%              a non-unique element in aStruct
%
% Output:
% -------
%   bStruct     Sorted array of unique elements in aStruct
%
%   m           Index array such that bStruct=aStruct(m)
% 
%   n           Index array such that aStruct=bStruct(n)

if ~exist('occurence','var')||strcmpi(occurence,'last')
    first_occurence=false;
elseif strcmpi(occurence,'first')
    first_occurence=true;
else
    error('Invalid sort option')
end

% Sort structure
[bStruct, index] = nestedSortStruct(aStruct, fieldnames(aStruct)');

% Find unique elements
nel=numel(aStruct);
equal_prev=false(nel,1);
for i=2:nel
    if isequal(bStruct(i-1),bStruct(i))
        equal_prev(i)=true;
    end
end
if ~any(equal_prev),
    m=index;
    n=(1:numel(m))';
    [dummy,ind]=sort(index);
    n=n(ind);
else
    de=diff([equal_prev;0]);
    ibeg=find(de==1);
    iend=find(de==-1);
    indexu=index;
    for i=1:numel(ibeg)
        if first_occurence
            indexu(ibeg(i):iend(i))=min(indexu(ibeg(i):iend(i)));
        else
            indexu(ibeg(i):iend(i))=max(indexu(ibeg(i):iend(i)));
        end
    end
    bStruct=bStruct(~equal_prev);
    m=indexu(~equal_prev);
    n=zeros(size(index));
    n(~equal_prev)=1:numel(m);
    for i=1:numel(ibeg)
        n(ibeg(i):iend(i))=n(ibeg(i));
    end
    [dummy,ind]=sort(index);
    n=n(ind);
end
