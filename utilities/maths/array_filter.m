function [ind,indv]=array_filter(arr,vals,opt)
% Find the indicies of elements of an array that appear in a list of test values
%
%   >> [ind,indv]=array_filter(arr,vals)
%   >> [ind,indv]=array_filter(arr,vals,opt)
%
% Input:
% ------
%   arr     Numerical array, cell array of strings, or array of structures
%          (where each field is numeric or logical scalar, or string).
%           Need not contain unique elements.
%   vals    List of test values of the same type (need not be unique)
%   opt     {optional] 'first' (default) or 'last':
%          Indicies in indv will be to first or last occurences in vals
%          (These two options will give same result if vals is a unique array)
%
% Output:
% -------
%   ind     indicies of elements of arr that appear in vals
%   indv    indicies of vals such that arr(ind)=vals(indv)
%
%
% Tip: It may be that not all elements of arr appear in vals. Test for this case
%   >> if numel(ind)~=numel(arr)


% Check input option
if ~exist('opt','var')||strcmpi(opt,'first')
    opt='first';
elseif strcmpi(opt,'last')
    opt='last';
else
    error('Invalid sort option')
end

% Sort input arrays, and check type
if (isnumeric(arr) && isnumeric(vals)) || (iscellstr(arr) && iscellstr(vals)) || ...
        (isobject(arr) && isobject(vals) && strcmp(class(arr),class(vals)))
    [asort,ia]=sort(arr(:));
    [vsort,iv]=unique(vals(:),opt);
elseif isstruct(arr) && isstruct(vals)
    nam=fieldnames(arr)';
    namv=fieldnames(vals)';
    if numel(nam)==numel(namv) && all(strcmp(nam,namv))
        [asort,ia]=uniqueNestedSortStruct(arr(:),opt);
        [vsort,iv]=uniqueNestedSortStruct(vals(:),opt);
    else
        error('Field names must all be the same if input arguments are structures')
    end
else
    error('Check input types')
end


% Find shared elements
i=1; j=1; na=numel(asort); nv=numel(vsort);
indv=zeros(size(asort));

if isnumeric(arr)
    while (i<=na && j<=nv)
        if asort(i)==vsort(j)
            indv(i)=j;  % non-zero elements are indices into vsort of elements that match asort
            i=i+1;
        else
            if asort(i)<vsort(j)
                i=i+1;
            else
                j=j+1;
            end
        end
    end
elseif isobject(arr)
    while (i<=na && j<=nv)
        if isequal(asort(i),vsort(j))
            indv(i)=j;  % non-zero elements are indices into vsort of elements that match asort
            i=i+1;
        else
            [tmp,ind]=sort([asort(i),vsort(j)]);    % ensures lexical ordering is always matched to sort and unique functions
            if ind(1)==1
                i=i+1;
            else
                j=j+1;
            end
        end
    end
elseif iscellstr(arr)
    while (i<=na && j<=nv)
        if strcmp(asort{i},vsort{j})
            indv(i)=j;  % non-zero elements are indices into vsort of elements that match asort
            i=i+1;
        else
            [tmp,ind]=sort([asort(i),vsort(j)]);    % ensures lexical ordering is always matched to sort and unique functions
            if ind(1)==1
                i=i+1;
            else
                j=j+1;
            end
        end
    end
else
    while (i<=na && j<=nv)
        if isequal(asort(i),vsort(j))
            indv(i)=j;  % non-zero elements are indices into vsort of elements that match asort
            i=i+1;
        else
            [tmp,ind]=nestedSortStruct([asort(i);vsort(j)],nam);
            if ind(1)==1
                i=i+1;
            else
                j=j+1;
            end
        end
    end
end

ind=find(indv>0);   % indicies of elements of asort that appear in vsort
indv=indv(ind);     % vsort(indv)=asort(ind)

[ind,ix]=sort(ia(ind));
indv=iv(indv);
indv=indv(ix);
