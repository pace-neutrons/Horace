function [alatt,angdeg,rotmat,ok,mess]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0)
% Extract lattice parameters and orientation matrix from rlu correction matrix and reference lattice parameters
%
%   >> [alatt,angdeg,rotmat,ok,mess]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0)
%
% Input:
% ------
%   rlu_corr        Conversion matrix to relate reference rlu to true rlu, accounting
%                  for the the true lattice parameters and orientation
%                       qhkl(i) = rlu_corr(i,j) * qhkl_0(j)
%   alatt0          Reference lattice parameters [a,b,c] (Angstroms)
%   angdeg0         Reference lattice angles [alf,bet,gam] (deg)
%
% Output:
% -------
%   alatt           True lattice parameters [a,b,c] (Angstroms)
%   angdeg          True lattice angles [alf,bet,gam] (degrees)
%   rotmat          Rotation matrix that relates crystal Cartesian coordinate frame of the true
%                  lattice and orientation as a rotation of the reference crystal frame. Coordinates
%                  in the two frames are related by 
%                       v(i)= rotmat(i,j)*v0(j)
%   ok              =true if all ok; =false otherwise
%   mess            Error message if ~ok; ='' if ok

[b0,arlu,angrlu,mess] = bmatrix(alatt0,angdeg0);
if ~isempty(mess)
    ok=false; return
end

% We have v_cryst0=b0*inv(rlu_corr)*v_rlu, so:
astar=b0*(rlu_corr\[1;0;0]);
bstar=b0*(rlu_corr\[0;1;0]);
cstar=b0*(rlu_corr\[0;0;1]);
V=det([astar,bstar,cstar]);     % a*.(b* x c*)
if V<=0
    ok=false; mess='New reciprocal lattice vectors are collinear or do not form a right-hand coordinate set'; return
end
a=(2*pi)*cross(bstar,cstar)/V;
b=(2*pi)*cross(cstar,astar)/V;
c=(2*pi)*cross(astar,bstar)/V;
alatt=[norm(a),norm(b),norm(c)];
angdeg=[acosd(dot(b,c)/(alatt(2)*alatt(3))), acosd(dot(c,a)/(alatt(3)*alatt(1))), acosd(dot(a,b)/(alatt(1)*alatt(2)))];

[b,arlu,angrlu,mess] = bmatrix(alatt,angdeg);
if ~isempty(mess)
    ok=false; return
end

rotmat=b*rlu_corr/b0;
ok=true;
mess='';
