function ihi=upper_bin_index(n_cumsum,n_buff)
% Get upper indices of ranges with sum of elements as close to n_buff as possible
%
%   >> ihi=upper_bin_index(n_cumsum,n_buff)
%
% Input:
% ------
%   n_cumsum    Cumulative sum of an array (more efficient if column vector)
%   n_buff      Maximum sum of elements of array in a range (subject to
%              a range having at least one element i.e. the element is not
%              split into more than one range)
%
% Output:
% -------
%   ihi         Indicies of the upper limits of each range (column vector)


% Original author: T.G.Perring
%
% $Revision: 909 $ ($Date: 2014-09-12 18:20:05 +0100 (Fri, 12 Sep 2014) $)


if ~iscolvector(n_cumsum), n_cumsum=n_cumsum(:); end

ind_max=10;     % initial length of output array
ihi=zeros(ind_max,1);
nbin=numel(n_cumsum);
j=0;            % previous upper range index
i=0;            % upper range index of previous range
n_tot=0;     % sum of elements in previous ranges
while i<nbin
    j=j+1;
    if j>ind_max
        ihi=[ihi;zeros(size(ihi))]; % double size of array if need to enlarge
    end
    inew = upper_index (n_cumsum, n_tot+n_buff);
    if inew==i
        i=i+1;  % always have at least one element in the range
    else
        i=inew;
    end
    ihi(j)=i;
    n_tot=n_cumsum(i);
end

% Remove unused trailing elements, and remove any ranges with zero sum.
% Pathological cases can give empty ranges
%  e.g. n_cumsum=[100,400,1200,2500,2500,2500,3600,3800] with n_buff=1000
ihi=ihi(1:j);
ihi=ihi(diff([0;n_cumsum(ihi)])>0);
