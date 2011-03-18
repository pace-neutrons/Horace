function [c1joint,c1unique,c2unique]=array_common(c1,c2,opt)
% Find the common elements of two arrays in the order they appeared in the first
% Works for cell arrays of strings too
%
%   >> c1joint=array_common(c1,c2)             % common elements
%   >> c1joint=array_common(c1,c2,'first')     % in the order of first appearance in c1 (default)
%   >> c1joint=array_common(c1,c2,'last')      % in the order of last appearance in c1
%
% Get the unique elements of first and second arrays in the order in which they appeared
% in the original arrays (according to first or last occurence as dictated by 'first' or 'last'
%
%   >> [c1joint,c1unique,c2unique]=array_common(...)
%
% All output is as column arrays

if ~exist('opt','var')||strcmpi(opt,'first')
    opt='first';
elseif strcmpi(opt,'last')
    opt='last';
else
    error('Invalid sort option')
end

c1=c1(:); c2=c2(:); % make columns
[csort1,ind1]=unique(c1(:),opt);
[csort2,ind2]=unique(c2(:),opt);

i=1; j=1; n1=numel(csort1); n2=numel(csort2);
common=false(size(csort1));
if isnumeric(c1) && isnumeric(c2)
    while (i<=n1 && j<=n2)
        if csort1(i)==csort2(j)
            common(i)=true;
            i=i+1;
            j=j+1;
        else
            if csort1(i)<csort2(j)
                i=i+1;
            else
                j=j+1;
            end
        end
    end
elseif iscellstr(c1) && iscellstr(c2)
    while (i<=n1 && j<=n2)
        if strcmp(csort1{i},csort2{j})
            common(i)=true;
            i=i+1;
            j=j+1;
        else
            [tmp,ind]=sort([csort1(i),csort2(j)]);  % ensures lexical ordering is always matched to sort and unique functions
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

c1joint=c1(sort(ind1(common)));

% Get unique lists
c1unique=c1(sort(ind1));
c2unique=c2(sort(ind2));
