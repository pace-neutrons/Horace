function [ind, neltot] = index_hist_elements (nel, bindim)
% Create index array to rearrange elements order after merging several histograms
%
%   >> [ind, neltot] = index_hist_elements (nel)
%   >> [ind, neltot] = index_hist_elements (nel, bindim)
%
% Input:
% ------
%   nel     Two-dimensional non-empty array with the number of elements in each bin
%           in the histograms, which are assumed to all have the same number
%           of bins.
%             If bindim==1: [default]
%               First column gives number of elements in each bin for first histogram
%               Second column gives number of elements in each bin for second histogram
%             If bindim==2:
%               First row gives number of elements in each bin for first histogram
%               Second row gives number of elements in each bin for second histogram
%
%   bindim  Orientation of array nel (see above)
%
% Output:
% -------
%   ind     If the elements of the histograms are concatenated so that
%               el_concat = hist1-bin1, hist1-bin2,...hist1-binN,hist2-bin1,hist2-bin2,...
%           then ind is the index array that places the elements in the order
%               el - hist1-bin1,hist2-bin2,...histM-bin1,hist1-bin2,hist2-bin2,...
%           That is:
%               el = el_concat(ind)
%           Note: ind is a column vector
%
%   neltot  Vector with the number of elements in each bin of the final histogram
%             If bindim==1: column vector
%             If bindim==2: row vector
%
%
% EXAMPLES
%(1)>> nel = [26,21,8;...
%             13, 4,24;...
%              9, 7, 5;...
%             16,13,15];
%   >> ind = index_hist_elements (nel);
%   >> iarray_to_matstr(ind,40)        % utility function
%   ans =
%       '[1:26,65:85,110:117,27:39,86:89,118:141,40:48,...'
%       '    90:96,142:146,49:64,97:109,147:161]'
%
%(2)>> ind = index_hist_elements (nel',2);  % equivalent to the above
%
%(3)>> nel=[26,13,0; 21,0,7];
%   >> [ind,neltot] = index_hist_elements (nel,2);
%   >> iarray_to_matstr(ind)
%   ans = [1:26,40:60,27:39,61:67]
%   >> neltot
%   neltot =
%       47    13     7
%
%(4)>> nel=[26,0,0,16; 21,0,7,0];
%   >> [ind,neltot] = index_hist_elements (nel,2);
%   >> iarray_to_matstr(ind)
%   ans = [1:26,43:70,27:42]
%   >> neltot
%   neltot =
%       47     0     7    16


% Original author: T.G.Perring
%
% $Revision: 815 $ ($Date: 2013-12-29 19:40:56 +0000 (Sun, 29 Dec 2013) $)


% Check input:
sz=size(nel);
if numel(sz)~=2 || prod(sz)==0
    error('Array with number of elements in each bin must be non-empty and two-dimensional')
end

if nargin==1
    bindim=1;
elseif ~(bindim==1||bindim==2)
    error('bindim must be equal to 1 or to 2')
end

if sz(1)==1 || sz(2)==1
    % Special case of one bin, or one histogram
    % -----------------------------------------
    ind=(1:sum(nel))';  % no reordering needed
    if nargout>1
        if sz(bindim)==bindim
            neltot=sum(nel);
        else
            neltot=nel;
        end
    end
    
else
    % General case
    % ------------
    % Get cumulative number of elements in bins for first hist, followed by second,..
    % then transpose to order indicies by hist for 1st bin, then by hist for 2nd...
    if bindim==1
        nhi=cumsum(nel(:));
        nhi=reshape(nhi,sz)';
        dn=nel';
    else
        nhi=cumsum(make_column(nel'));
        nhi=reshape(nhi,[sz(2),sz(1)])';
        dn=nel;
    end
    
    if nhi(end)>0   % at least one bin has elements
        % Retain ranges with one or more elements only
        ok=(dn>0);
        dn=dn(ok);
        nhi=nhi(ok);
        nlo=nhi-dn+1;
        
        % Ranges for entries in ind
        ihi=cumsum(dn);
        ilo=ihi-dn+1;
        
        % Fill ind
        ind=zeros(nhi(end),1);
        for i=1:numel(dn)
            ind(ilo(i):ihi(i)) = nlo(i):nhi(i);
        end
    else
        ind=[];
    end
    
    % Return total number elements in the bins, if requested
    if nargout>1
        if bindim==1
            neltot=sum(nel,2);
        else
            neltot=sum(nel,1);
        end
    end
    
end
