function ind = ind_from_nrange (nstart, nend)
% Create index array from a list of ranges
%
%   >> ind = ind_from_nrange (nstart, nend)
%
% Input:
% ------
%   nstart  Array of starting values of ranges of indicies
%   nend    Array of finishing values of ranges of indicies
%           It is assumed that nend(i)>=nbeg(i), and that
%          nbeg(i+1)>nend(i). That is, the ranges
%          contain at least one element, and they do not
%          overlap. No checks are performed to ensure these
%          conditions are satisfied.
%           nstart and nend can be empty.
%
% Output:
% -------
%   ind     Output array: column vector
%               ind=[nstart(1):nend(1),nstart(2):nend(2),...]'
%           If nstart and nend are empty, then ind is empty.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


if numel(nstart)==numel(nend)
    % Catch trivial case of no ranges
    if numel(nstart)==0
        ind=zeros(0,1);
        return
    end
    % Make input arrays columns if necessary
    if ~iscolvector(nstart), nstart=nstart(:); end
    if ~iscolvector(nend), nend=nend(:); end
    % Create index array using cumsum - shoudl be fast in general
    nel=nend-nstart+1;
    nelcum=cumsum(nel);
    ix=[1;nelcum(1:end-1)+1];
    dind=[nstart(1);nstart(2:end)-nend(1:end-1)];
    ind=ones(nelcum(end),1);
    ind(ix)=dind;
    ind=cumsum(ind);
else
    error('Number of elements in input arrays incompatible')
end
