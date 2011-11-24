function [ind,indv]=array_filter(arr,vals,opt)
% Find the indicies of elements of an array that appear in a list of values
% Works for cell arrays of strings too
%
%   >> [ind,indv]=array_filter(arr,vals)
%   >> [ind,indv]=array_filter(arr,vals,opt)
%
%   arr     need not contain unique values
%   vals    list of test values (need not be unique)
%   opt     {optional] 'first' (default) or 'last':
%          indicies in indv will be to first or last occurences in vals
%          (will give same result if vals is a unique array)
%
%   ind     indicies of elements of arr that appear in vals
%   indv    indicies of vals such that arr(ind)=vals(indv)
%
% It may be that not all elements of arr appear in vals. Test for this case
%   >> if numel(ind)~=numel(arr)

if ~exist('opt','var')||strcmpi(opt,'first')
    opt='first';
elseif strcmpi(opt,'last')
    opt='last';
else
    error('Invalid sort option')
end

[asort,ia]=sort(arr(:));
[vsort,iv]=unique(vals(:),opt);

i=1; j=1; na=numel(asort); nv=numel(vsort);
indv=zeros(size(asort));

if isnumeric(arr) && isnumeric(vals)
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
elseif iscellstr(arr) && iscellstr(vals)
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
    error('Check input types')
end

ind=find(indv>0);   % indicies of elements of asort that appear in vsort
indv=indv(ind);     % vsort(indv)=asort(ind)

[ind,ix]=sort(ia(ind));
indv=iv(indv);
indv=indv(ix);
