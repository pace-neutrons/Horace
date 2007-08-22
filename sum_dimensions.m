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
%   s       Output array: s.p1 is the sum for the first dimensions, s.p2 for
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
    s.p1 = sum(a,2,'native');
    s.p2 = sum(a,1,'native')';
    return
end

if ndim==3
    temp = sum(a,3,'native');
    s.p1 = sum(temp,2,'native');
    s.p2 = sum(temp,1,'native')';
    s.p3 = squeeze(sum(sum(a,1,'native'),2,'native'));
    return
end

if ndim==4
    temp = squeeze(sum(sum(a,3,'native'),4,'native'));
    s.p1 = sum(temp,2,'native');
    s.p2 = sum(temp,1,'native')';
    temp = squeeze(sum(sum(a,1,'native'),2,'native'));
    s.p3 = sum(temp,2,'native');
    s.p4 = sum(temp,1,'native')';
    return
end

% for 5 and more dimensions do a loop (faster bifurcation algorithm possible, but don't bother unless becomes critical)

for idim=1:ndim
    temp = a;
    for i=1:ndim
        if i~=idim
            temp = sum(temp,i,'native');
        end
    end
    nam = ['p',num2str(idim)];
    s.(nam) = squeeze(temp);
    if size(s.(nam),2)>1
        s.(nam) = s.(nam)';
    end
end
