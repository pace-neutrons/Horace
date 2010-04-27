function  [spe,spe_header]=build_default_spe_structure(spe_header)
% function builds default spe structure to reserve its place in a file
%   efix       Fixed energy (ei or ef depending on emode)
%   emode      Emode=1 direct geometry, =2 indirect geometry
%   alatt      Lattice parameters (Angstroms)
%   angdeg     Lattice angles (deg)
%   cu         First vector defining scattering plane (r.l.u.)
%   cv         Second vector defining scattering plane (r.l.u.)
%   psi        Orientation angle (rad)
%   omega      --|
%   dpsi         |  Crystal misorientation description (rad)
%   gl           |  (See notes elsewhere e.g. Tobyfit manual
%   gs         --|
%   en         Energy bin boundaries (meV) [column vector]
%   uoffset    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
%   u_to_rlu   Matrix (4x4) of projection axes in hkle representation
%                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   ulen       Length of projection axes vectors in Ang^-1 or meV [row vector]
%   ulabel     Labels of the projection axes [1x4 cell array of character strings]

% default ndim 4, all other will be redefined;
ndim= 4;

spe.filename = spe_header.filename;
spe.filepath = spe_header.filepath;
spe.alatt=[2*pi, 2*pi, 2*pi];     %    Lattice parameters (Angstroms)
spe.efix =100;            %      Fixed energy (ei or ef depending on emode)
spe.emode=1;             %    Emode=1 direct geometry, =2 indirect geometry
spe.angdeg=[90,90,90];     %    Lattice angles (deg)
spe.cu=[1;0;0];        %    First vector defining scattering plane (r.l.u.)
spe.cv=[0;1;0];         %    Second vector defining scattering plane (r.l.u.)
spe.psi=0;        %    Orientation angle (rad)
spe.omega=0;      %    --|
spe.dpsi=0;       %      |  Crystal misorientation description (rad)
spe.gl  =0;       %      |  (See notes elsewhere e.g. Tobyfit manual
spe.gs = 0;       %    --|
spe.en =zeros(200,1);       %    Energy bin boundaries (meV) [column vector]
spe.uoffset =zeros(4,1);    %    Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
spe.u_to_rlu=eye(4);      %    Matrix (4x4) of projection axes in hkle representation
                          %                      u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.              
spe.ulen =[1,1,1,1];       %    Length of projection axes vectors in Ang^-1 or meV [row vector]
spe.ulabel={'\zeta','\xi','\eta','E'};   %    Labels of the projection axes [1x4 cell array of character strings]
%
spe.dax  =[1,2,3,4];
spe.dax  =1:ndim;
spe.iax  =zeros(1,ndim);
spe.iint =zeros(2,size(spe.iax,2));
spe.pax  =1:ndim;
spe.p    =repmat({[0;1]},1,ndim);



this_fields    = fieldnames(spe);
not_in_fields  = ~ismember(spe_header.spe_field_names,this_fields);
addfields      = spe_header.spe_field_names(not_in_fields);
% define new and unknown addfiedls as simple vectors; they will be
% owerwritten anyway. 
for i=1:numel(addfields)
    spe.(addfields{i})=zeros(1,4);
end
   


