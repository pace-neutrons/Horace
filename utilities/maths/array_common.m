function [c1joint,c1unique,c2unique]=array_common(c1,c2,opt)
% Find the common elements of two arrays in the order they appeared in the first.
%
% Common use:
%   >> c1joint=array_common(c1,c2)             % common elements
%   >> c1joint=array_common(c1,c2,'first')     % in the order of first appearance in c1 (default)
%   >> c1joint=array_common(c1,c2,'last')      % in the order of last appearance in c1
%
% Additional output arguments:
%   >> [c1joint,c1unique,c2unique]=array_common(...)
%
% Input:
% ------
%   c1          Numerical array, cell array of strings, or array of structures
%              (where each field is numeric or logical scalar, or string).
%               Need not contain unique elements.
%
%   c2          Second array of same type; need not contain unique elements.
%
%   opt         'first' [default] or 'last' - common element order in the
%              order of first or last appearance in c1.
%
% Output:
% -------
%   c1joint     Common elements of c1 and c2 in the order in which they 
%              appeared in c1 - either by their first or last appearance in
%              c1 according to the value of input argument opt (see above).
%              [Column array]
%
%   c1unique    Unique elements of first array in the order they appeared
%              in the original arrays according to first or last occurence
%              determined by input argument opt (see above)
%              [Column array]
%
%   c2unique    The same for the second array
%              [Column array]
%
% The last two argument are available as the routine needs to sort unique
% elements as part of its internal workings, and this can be an expensive
% procedure.


% Check input option
if ~exist('opt','var')||strcmpi(opt,'first')
    opt='first';
elseif strcmpi(opt,'last')
    opt='last';
else
    error('Invalid sort option')
end

% Sort input arrays, and check type
c1=c1(:); c2=c2(:); % make columns
if (isnumeric(c1) && isnumeric(c2)) || (iscellstr(c1) && iscellstr(c2)) || ...
        (isobject(c1) && isobject(c2) && strcmp(class(c1),class(c2)))
    [csort1,ind1]=unique(c1(:),opt);
    [csort2,ind2]=unique(c2(:),opt);
elseif isstruct(c1) && isstruct(c2)
    nam1=fieldnames(c1)';
    nam2=fieldnames(c2)';
    if numel(nam1)==numel(nam2) && all(strcmp(nam1,nam2))
        [csort1,ind1]=uniqueNestedSortStruct(c1(:),opt);
        [csort2,ind2]=uniqueNestedSortStruct(c2(:),opt);
    else
        error('Field names must all be the same if input arguments are structures')
    end
else
    error('Check input types')
end
    
% Find common elements
i=1; j=1; n1=numel(csort1); n2=numel(csort2);
common=false(size(csort1));

if isnumeric(c1)
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
elseif isobject(c1)
    while (i<=n1 && j<=n2)
        if isequal(csort1(i),csort2(j))
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
elseif iscellstr(c1)
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
    while (i<=n1 && j<=n2)
        if isequal(csort1(i),csort2(j))
            common(i)=true;
            i=i+1;
            j=j+1;
        else
            [tmp,ind]=nestedSortStruct([csort1(i);csort2(j)],nam1);
            if ind(1)==1
                i=i+1;
            else
                j=j+1;
            end
        end
    end
end

c1joint=c1(sort(ind1(common)));

% Get unique lists
if nargout>=2
    c1unique=c1(sort(ind1));
end
if nargout>=3
    c2unique=c2(sort(ind2));
end
