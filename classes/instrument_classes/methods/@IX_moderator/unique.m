function [bObj, m, n] = unique(aObj, occurence)
% Equivalent to intrinsic Matlab unique but here for objects
%
%   >> [bObj, m, n] = unique(aObj, occurence)
%
% Input:
% ------
%   aObj        Array of input objects
%
%   occurence   Character string 'last' [default] or 'first'; indicates if the index
%              element in output array m points to first or last occurence of
%              a non-unique element in aObj
%
% Output:
% -------
%   bObj        Sorted array of unique elements in aObj
%
%   m           Index array such that bObj=aObj(m)
%
%   n           Index array such that aObj=bObj(n)


% This is a template that should work for any object so long as a sort method is defined

if ~exist('occurence','var')||strcmpi(occurence,'last')
    first_occurence=false;
elseif strcmpi(occurence,'first')
    first_occurence=true;
else
    error('Invalid sort option')
end

% Sort structure
[bObj, index] = sort(aObj);

% Find unique elements
nel=numel(aObj);
equal_prev=false(nel,1);
for i=2:nel
    if isequal(bObj(i-1),bObj(i))
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
    bObj=bObj(~equal_prev);
    m=indexu(~equal_prev);
    n=zeros(size(index));
    n(~equal_prev)=1:numel(m);
    for i=1:numel(ibeg)
        n(ibeg(i):iend(i))=n(ibeg(i));
    end
    [dummy,ind]=sort(index);
    n=n(ind);
end
