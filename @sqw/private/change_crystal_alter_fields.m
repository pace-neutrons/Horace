function [header,data,ok,mess]=change_crystal_alter_fields(header_in,data_in,varargin)
% Change fields in the header and data structures when change crystal lattice parameters and orientation
%
%   >> [header,data]=change_crystal_alter_fields(header_in,data_in,alatt)
%   >> [header,data]=change_crystal_alter_fields(header_in,data_in,alatt,angdeg)
%   >> [header,data]=change_crystal_alter_fields(header_in,data_in,alatt,angdeg,rotmat)
%   >> [header,data]=change_crystal_alter_fields(header_in,data_in,rlu_corr)

header=header_in;
data=data_in;
ok=true;
mess='';

% Get alatt, angdeg and rlu_corr
alatt0=data_in.alatt;
angdeg0=data_in.angdeg;

narg=numel(varargin);
if narg==0
    return
    
elseif narg==1 && isnumeric(varargin{1}) && numel(size(varargin{1})==2) && all(size(varargin{1})==[3,3])     % rlu_corr
    rlu_corr=varargin{1};
    [alatt,angdeg,ok,mess]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0);
    if ~ok, return, end
    
elseif narg<=3
    alatt=varargin{1}(:)';  % ensure row vector
    if ~isnumeric(alatt)||numel(alatt)~=3||any(alatt<=0)
        ok=false; mess='Check new lattice parameters [a,b,c] are all greater than zero'; return
    end
    if narg>=2
        angdeg=varargin{2}(:)';     % ensure row vector
        if ~isnumeric(angdeg)||numel(angdeg)~=3||any(angdeg<=0)
            ok=false; mess='Check new lattice angles [alf,bet,gam] are all greater than zero'; return
        end
    else
        angdeg=angdeg0;
    end
    if narg>=3
        rotmat=varargin{3};
        if ~(isnumeric(rotmat) && numel(size(rotmat)==2) && all(size(rotmat)==[3,3]) && abs(det(rotmat)-1)<1e-12)
            ok=false; mess='Check rotation matrix is orthogonal with determinant=+1'; return
        end
    else
        rotmat=eye(3);
    end
    [b0,arlu,angrlu,mess] = bmatrix(alatt0,angdeg0);
    if ~isempty(mess), ok=false; return, end

    [b,arlu,angrlu,mess] = bmatrix(alatt,angdeg);
    if ~isempty(mess), ok=false; return, end
    
    rlu_corr=b\rotmat*b0;

else
    ok=false; mess='Check number of arguments'; return
end

% Change fields of header and data as required
if ~isempty(header)     % not dnd-type object
    if iscell(header)   % multiple spe files
        for i=1:numel(header)
            header{i}.alatt=alatt;
            header{i}.angdeg=angdeg;
            header{i}.cu=(rlu_corr*header{i}.cu')';
            header{i}.cv=(rlu_corr*header{i}.cv')';
            header{i}.uoffset(1:3)=rlu_corr*header{i}.uoffset(1:3);
            header{i}.u_to_rlu(1:3,1:3)=rlu_corr*header{i}.u_to_rlu(1:3,1:3);
        end
    else
        header.alatt=alatt;
        header.angdeg=angdeg;
        header.cu=(rlu_corr*header.cu')';
        header.cv=(rlu_corr*header.cv')';
        header.uoffset(1:3)=rlu_corr*header.uoffset(1:3);
        header.u_to_rlu(1:3,1:3)=rlu_corr*header.u_to_rlu(1:3,1:3);
    end
end

data.alatt=alatt;
data.angdeg=angdeg;
data.uoffset(1:3)=rlu_corr*data.uoffset(1:3);
data.u_to_rlu(1:3,1:3)=rlu_corr*data.u_to_rlu(1:3,1:3);
