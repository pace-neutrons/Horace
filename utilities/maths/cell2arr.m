function a=cell2arr(acell,squeeze_col)
% Convert a cell array of arrays into a multi-dimensional array
%
%   >> a=cell2arr(acell)
%   >> a=cell2arr(acell,true)
%
% Input:
% ------
%   acell       Cell array of numeric arrays
%   squeeze_col [Optional] If true, then if the arrays are all
%               column vectors or empty arrays size [n,0] then
%               the output array will be squeezed so that it is
%               just two dimensional
%
% Output:
% -------
%   a           Multi-dimensional array created from acell, by
%               first increasing the size and dimensionality of each
%               array to match the largest array (padding with zeros as
%               required), then concatenating along an extra dimension.
%               If squeeze_col==true then the second dimension is squeezed
%               if all column vectors (see above)
%
% EXAMPLES
%   acell={[2,4,6]',[3,4;5,6]}
%   a=cell2arr(acell)
%       a(:,:,1) =              a(:,:,2) =
%           2     0                 3     4
%           4     0                 5     6
%           6     0                 0     0
%
%   acell={[2,4,6]',[11,12]'}
%   a=cell2arr(acell,true)
%       a =
%           2    11
%           4    12
%           6     0


% T.G.Perring, 18 Dec 2014


% Determine if columns are to be squeezed
if nargin==2
    if isscalar(squeeze_col)
        squeeze_col=logical(squeeze_col);
    else
        error('Check ''squeeze_col'' is a logical scalar or 0 or 1')
    end
else
    squeeze_col=false;
end


% Combine arrays
n=numel(acell);

if n>1
    % Get the size and number of dimensions in each array
    sz=cell(n,1);
    nd=zeros(n,1);
    not_empty=true(n,1);
    for i=1:n
        sz{i}=size(acell{i});
        nd(i)=numel(sz{i});
        if isempty(acell{i})
            not_empty(i)=false;
        end
    end
    
    % Get the size of the output array
    szarr=NaN(n,max(nd));
    for i=1:n
        szarr(i,1:nd(i))=sz{i};
    end
    szmax=max(szarr,[],1);
    szmax=szmax(~isnan(szmax));

    % Fill output
    if squeeze_col && numel(szmax)==2 && szmax(2)==1
        % Non-empty array are column vectors and we requested to squeeze them
        a=zeros(szmax(1),n) ;
        for i=find(not_empty)'; % row vector of indicies of non-empty arrays in acell
            a(1:sz{i}(1),i)=acell{i};
        end
        
    else
        % General case
        ind=cell(1,numel(szmax));
        a=zeros([szmax,n]);
        for i=find(not_empty)'; % row vector of indicies of non-empty arrays in acell
            for j=1:nd(i)
                ind{j}=1:sz{i}(j);
            end
            a(ind{:},i)=acell{i};
        end
        
    end    
    
elseif n==1
    % Trivial case of single array
    a=acell{1};
    
elseif n==0
    % Empty cell array => []
    a=[];
end
