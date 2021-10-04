function obj=make_sqw_data_from_proj(obj,lattice,proj_in)
% Create data filed for sqw object from input of the form
%
%   >> [data,mess] = make_sqw_data_from_proj(lattice,proj)
%
% Input:
% ------
%   lattice        [Optional] Defines crystal lattice: [a,b,c,alpha,beta,gamma]
%                  Assumes to be [2*pi,2*pi,2*pi,90,90,90] if not given.
%
%   proj            Projection structure or object.
%
% Output:
% -------
%   data            Data structure of a valid data field in a dnd-type sqw object



% Original author: T.G.Perring
%


% Check projection
if isstruct(proj_in) || isa(proj_in,'projaxes')
    proj = projaxes(proj_in);
else
    error('HORACE:data_sqw_dnd:invalid_argument',...    
    'projection must be valid projection structure or projaxes object')
end

[~, u_to_rlu, ulen, mess] = projaxes_to_rlu(proj, lattice(1:3), lattice(4:6));
if ~isempty(mess)   % problem calculating ub matrix and related quantities
    error('HORACE:data_sqw_dnd:invalid_argument',...
        'Check lattice parameters and projection axes');
end


% Fill data structure
ndim=numel(obj.p);
sz=ones(1,max(2,ndim));
for i=1:ndim
    sz(i)=numel(obj.p{i})-1;
end
obj.filename = '';
obj.filepath = '';
obj.alatt=lattice(1:3);
obj.angdeg=lattice(4:6);
obj.uoffset=proj.uoffset;
%
obj.u_to_rlu=zeros(4,4); obj.u_to_rlu(1:3,1:3)=u_to_rlu; obj.u_to_rlu(4,4)=1;
%TODO: this is part of axes_block. To be moved out there
obj.ulen=[ulen,1];
obj.ulabel=proj.lab;

obj.s=zeros(sz);
obj.e=zeros(sz);
obj.npix=ones(sz);
obj.img_db_range = dnd_binfile_common.calc_img_db_range(obj);


