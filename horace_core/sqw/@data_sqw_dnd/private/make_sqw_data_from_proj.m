function [data,mess]=make_sqw_data_from_proj(data,lattice,proj_in,p1,p2,p3,p4)
% Create data filed for sqw object from input of the form
%
%   >> [data,mess] = make_sqw_data_from_proj(lattice,proj,p1,p2,p3,p4)
%
% Input:
% ------
%   lattice        [Optional] Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%                  Assumes to be [2*pi,2*pi,2*pi,90,90,90] if not given.
%
%   proj            Projection structure or object.
%
%   p1,p2,p3,p4     Binning descriptors, that give bin boundaries or integration
%                  ranges for each of the four axes of momentum and energy. They
%                  each have one fo the forms:
%                   - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%                   - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
%                   - [pint]                    (interpreted as [pint,pint]
%                   - [] or empty               (interpreted as [0,0]
%                   - scalar numeric cellarray  (interpreted as bin boundaries)
%
% Output:
% -------
%   data            Data structure of a valid data field in a dnd-type sqw object
%   mess            If no problems, mess=''; otherwise contains error message


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)



% Check projection
if isstruct(proj_in) || isa(proj_in,'projaxes')
    proj = projaxes(proj_in);
else
    mess='projection must be valid projection structure or projaxes object';
    return
end

[rlu_to_ustep, u_to_rlu, ulen, mess] = projaxes_to_rlu(proj, lattice(1:3), lattice(4:6));
if ~isempty(mess)   % problem calculating ub matrix and related quantities
    mess='Check lattice parameters and projection axes';
    return
end

% Check the binning and get dimensionality
[iax,iint,pax,p,mess]=make_sqw_data_calc_ubins(p1,p2,p3,p4);
if ~isempty(mess)
    return
end

% Fill data structure
ndim=numel(p);
sz=ones(1,max(2,ndim));
for i=1:ndim
    sz(i)=numel(p{i})-1;
end
data.filename = '';
data.filepath = '';
data.title = '';
data.alatt=lattice(1:3);
data.angdeg=lattice(4:6);
data.uoffset=proj.uoffset;
data.u_to_rlu=zeros(4,4); data.u_to_rlu(1:3,1:3)=u_to_rlu; data.u_to_rlu(4,4)=1;
data.ulen=[ulen,1];
data.ulabel=proj.lab;
data.iax=iax;
data.iint=iint;
data.pax=pax;
data.p=p;
data.dax=1:ndim;
data.s=zeros(sz);
data.e=zeros(sz);
data.npix=ones(sz);

mess='';
