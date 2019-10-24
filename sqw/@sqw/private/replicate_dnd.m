function dout = replicate_dnd (din, dref)
% Make a higher dimensional dataset from a lower dimensional dataset by
% replicating the data along the extra dimensions of a reference dataset.
%
% The algorithm requires that the plot axes match in the input and reference
% datasets.
%
%   >> dout = replicate (din, dref)
%
% Input:
% ------
%   din     dnd structure or array of structures
%
%   dref    Reference dnd structure to use as template for expanding the 
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
%   dout    Output dnd structure.


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


% Check that plot axes are common, and that the dref has greater or equal dimensionality
nd_in = numel(din.pax);
nd_ref= numel(dref.pax);
size_in = size(din.s);
size_ref= size(dref.s);

if nd_in>nd_ref
    % Case of nd_in>=1:
    error('Reference dataset must have greater or equal dimensionality of dataset to be replicated')
elseif nd_in==0
    % Catch special case of nd_in==0 (loops for nd_in>0 later on won't work)
    dout=dref;
    dout.s=din.s*ones(size(dref.s));
    dout.e=din.e*ones(size(dref.s));
    dout.npix=din.npix*ones(size(dref.s));
    return
else
    % Have 1 =< nd_in <= nd_ref
    dim_common=false(1,nd_ref);
    for i=1:nd_in
        ipax=find(dref.pax==din.pax(i));
        if ~isempty(ipax)   % axis common
            dim_common(ipax)=true;
            if size_in(i)~=size_ref(ipax)
                error('One or more plot axes shared by the input and reference datasets have different length')
            end
        else
            error ('Input and reference datasets do not share the same plot axes')
        end
    end
    dout = dref;
    if nd_in==nd_ref    % case of matching dimensionality - just transfer signal
        dout.s = din.s;
        dout.e = din.e;
        dout.npix = din.npix;
    else
        permute_axes=[find(dim_common),find(~dim_common)];
        size_repmat=size_ref;
        size_repmat(dim_common)=1;
        dout.s=repmat(ipermute(din.s,permute_axes),size_repmat);
        dout.e=repmat(ipermute(din.e,permute_axes),size_repmat);
        dout.npix=repmat(ipermute(din.npix,permute_axes),size_repmat);
    end
end
