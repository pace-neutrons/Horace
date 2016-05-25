function vout = replicate_array (v, n)
% Replicate array elements according to list of repeat indicies
%
%   >> vout = replicate_array (v, n)
%
% Input:
% ------
%   v       Array of values
%   n       List of number of times to replicate each value
%
% Output:
% -------
%   vout    Output array: column vector
%               vout=[v(1)*ones(1:n(1)), v(2)*ones(1:n(2), ...)]'

% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

if numel(n)==numel(v)
    if ~isempty(n)
        % Get the bin index for each pixel
        nend=cumsum(n(:));
        nbeg=nend-n(:)+1;   % nbeg(i)=nend(i)+1 if n(i)==0, but that's OK below
        nbin=numel(n);
        ntot=nend(end);
        vout=zeros(ntot,1);
        for i=1:nbin
            vout(nbeg(i):nend(i))=v(i);     % if ni)=0, this assignment does nothing
        end
    else
        vout=zeros(0,1);
    end
else
    error('Number of elements in input array(s) incompatible')
end
