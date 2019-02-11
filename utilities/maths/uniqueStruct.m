function [bStruct, m, n] = uniqueStruct(aStruct, varargin)
% Equivalent to intrinsic Matlab unique but here for structures
%
%   >> [bStruct m, n] = uniqueStruct(aStruct)
%   >> [bStruct m, n] = uniqueStruct(aStruct, occurence)
%   >> [bStruct m, n] = uniqueStruct(...,'legacy')
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
%  'legacy'     If present, then the output array m (below) follows the 
%              legacy behaviour (i.e. Matlab 2012b and earlier)
%
% Output:
% -------
%   bStruct     Sorted array of unique elements in aStruct
%
%   m           Index array such that bStruct=aStruct(m). Note that m has
%              the indicies of the last occurence of repeated elements by
%              default. This accords with the legacy (i.e. pre-c.2012) behaviour
%              of the built-in function unique. Set the input argument
%              occurence to alter this behaviour.
% 
%   n           Index array such that aStruct=bStruct(n)


first_occurence=true;
legacy = false;

nopt = numel(varargin);
if nopt>=1
    if numel(varargin{end})>=2 && strncmpi(varargin{end},'legacy',numel(varargin{end}))
        nopt = nopt-1;
        legacy = true;
    end
end
if nopt<=1
    if nopt==1
        if numel(varargin{1})>=2 && strncmpi(varargin{1},'last',numel(varargin{1}))
            first_occurence=false;
        elseif strncmpi(varargin{1},'first',numel(varargin{1}))
            first_occurence=true;
        else
            error('Invalid value for sort option')
        end
    else
        if legacy
            first_occurence=false;
        end
    end
else
    error('Check number and validity of input arguments')
end

% Sort structure
if ~(isstruct(aStruct) && isvector(aStruct))
    error('Input to be sorted can only be a row or column vector structure')
end
[bStruct, index] = sortStruct(aStruct, fieldnames(aStruct)');

% Find unique elements
nel=numel(aStruct);
equal_prev=false(nel,1);
for i=2:nel
    if isequal(bStruct(i-1),bStruct(i))
        equal_prev(i)=true;
    end
end
if ~any(equal_prev)
    m=index;
    n=(1:numel(m))';
    [~,ind]=sort(index);
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
    [~,ind]=sort(index);
    n=n(ind);
end

% Orient vectors to follow convention for Matlab intrinsic function unique
% Just exhaustively check, rather than rely on (non-)legacy behaviour above
if legacy
    if isrow(aStruct)
        if ~isrow(bStruct), bStruct = bStruct(:)'; end
        if ~isrow(m), m = m(:)'; end
        if ~isrow(n), n = n(:)'; end
    else
        if ~iscolumn(bStruct), bStruct = bStruct(:); end
        if ~iscolumn(m), m = m(:); end
        if ~iscolumn(n), n = n(:); end
    end
else
    if isrow(aStruct)
        if ~isrow(bStruct), bStruct = bStruct(:)'; end
    else
        if ~iscolumn(bStruct), bStruct = bStruct(:); end
    end
    if ~iscolumn(m), m = m(:); end
    if ~iscolumn(n), n = n(:); end
end
