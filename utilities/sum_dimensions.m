function s = sum_dimensions(a)
% For each dimension, sums along all other dimensions to produce a
% one-dimensional array for each dimension.
%
% Ouput has same type as input.
%
% Syntax:
%   >> s = sum_dimensions(a)
%
% Input:
% ------
%   a       Input array
%
% Output:
% -------
%   s       Output array: s{1} is the sum for the first dimensions, s{2} for
%           the second etc. Each field is a column vector.

% Original author: T.G.Perring
%
% $Revision: 1.1 $ ($Date: 2005/07/28 13:18:40 $)
%
% Horace v0.1   J. van Duijn, T.G.Perring

n = size(a);
ndim = length(n);

% treat 2,3,4 dimensional arrays as special cases to speed up evaluation
if ndim==2
    s=cell(1,2);
    s{1} = sum(a,2,'native');
    s{2} = sum(a,1,'native')';
    return
end

if ndim==3
    s=cell(1,3);
    temp = sum(a,3,'native');
    s{1} = sum(temp,2,'native');
    s{2} = sum(temp,1,'native')';
    s{3} = squeeze(sum(sum(a,1,'native'),2,'native'));
    return
end

if ndim==4
    s=cell(1,4);
    temp = squeeze(sum(sum(a,3,'native'),4,'native'));
    s{1} = sum(temp,2,'native');
    s{2} = sum(temp,1,'native')';
    temp = squeeze(sum(sum(a,1,'native'),2,'native'));
    s{3} = sum(temp,2,'native');
    s{4} = sum(temp,1,'native')';
    return
end

% for 5 or more dimensions do a loop (faster bifurcation algorithm possible, but don't bother unless becomes critical)

s=cell(1,ndim);
for idim=1:ndim
    temp = a;
    for i=1:ndim
        if i~=idim
            temp = sum(temp,i,'native');
        end
    end
    s{idim} = squeeze(temp);
    if size(s{idim},2)>1
        s{idim} = s{idim}';
    end
end
