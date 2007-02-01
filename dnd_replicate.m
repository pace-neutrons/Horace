function dout = dnd_replicate (din, dref)
% Make a higher dimensional dataset from a lower dimensional dataset by
% replicating the data along the extra dimensions.
%
% Syntax:
%   >> dout = replicate (din, dref)
%
% Input:
% ------
%   din     Dataset structure.
%           Type >> help dnd_checkfields for a full description of the fields
%
%   dref    Reference dataset structure to use as template for expanding the 
%           input straucture.
%           - The plot axes of din must also be plot axes of dref, and the number
%           of points along these common axes must be the same, although the
%           numerical values of the coordinates need not be the same.
%           - The data is expanded along the plot axes of dref that are 
%           integration axes of din. 
%           - The annotations etc. are taken from the reference dataset.
%
% Output:
% -------
%   dout    Output dataset structure.
%

% Original author: T.G.Perring
%
% $Revision: 73 $ ($Date: 2005-08-24 17:48:25 +0100 (Wed, 24 Aug 2005) $)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% Check that plot axes are common, and that the dref is greater or equal dimensionality
nd_in = length(din.pax);
nd_ref= length(dref.pax);
size_in = size(din.s);
size_ref= size(dref.s);

if nd_in>nd_ref
    % Case of nd_in>=1:
    error('Reference dataset must have greater or equal dimensionality of dataset to be replicated')
elseif nd_in==0
    % Catch special case of nd_in==0 (loops for nd_in>0 later on won't work)
    dout=dref;
    dout.s=din.s*ones(size(dref.s));
    dout.e=din.s*ones(size(dref.s));
    dout.n=din.s*ones(size(dref.s));
    return
else
    pax_common=zeros(1,nd_in);      % list of indicies of plot axes of dref that are shared by din
    pax_expand=ones(1,nd_ref);      % indicies of plot axes of dref not shared by din
    for i=1:nd_in
        ipax=find(dref.pax==din.pax(i));
        if ~isempty(ipax)   % axis found
            pax_common(i)=ipax;
            pax_expand(ipax)=0;
            if size_in(i)~=size_ref(ipax)
                error('One or more plot axes shared by the input and reference datasets have different length')
            end
        end
    end
    pax_expand = find(pax_expand~=0);
    if all(pax_common)      % all plot axes of din shared by dref - can proceed
        dout = dref;
        if nd_in==nd_ref    % case of matching dimensionality - just transfer signal
            dout.s = din.s;
            dout.e = din.e;
            dout.n = din.n;
        else
            permute_axes=[pax_common,pax_expand];
            din.s=ipermute(din.s,permute_axes); % match the projection axes with dref
            din.e=ipermute(din.e,permute_axes);
            din.n=ipermute(din.n,permute_axes);
            size_repmat=size_ref;
            size_repmat(pax_common)=1;
            dout.s=repmat(din.s,size_repmat);
            dout.e=repmat(din.e,size_repmat);
            dout.n=repmat(din.n,size_repmat);
        end
    else
        error ('Input and reference datasets do not share the same plot axes')
    end
end
