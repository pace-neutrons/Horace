function  [alatt,angdeg,rlu_corr]=parse_change_crystal_arguments_(alatt0,angdeg0,header,varargin)
% process input parameters for change crystal routine and
% return standard form of the arguments to use in change_crystal
% Most commonly:
%   >> [alatt,angdeg,cor_mat] = change_crystal (w,alatt0,angdeg0,rlu_corr)
%                               change lattice parameters and orientation
%
% OR
%   >> [alatt,angdeg,cor_mat] = change_crystal (w, alatt)
%                               change just length of lattice vectors
%   >> [alatt,angdeg,cor_mat] = change_crystal (w, alatt, angdeg)
%                               change all lattice parameters
%   >> [alatt,angdeg,cor_mat] = change_crystal (w, alatt, angdeg, rotmat)
%                               change lattice parameters and orientation
%   >> [alatt,angdeg,cor_mat] = change_crystal (w, alatt, angdeg, u, v)   %
%                               change lattice parameters and redefine u, v
%                               (works on sqw objects only)


narg=numel(varargin);
if narg==1 && isnumeric(varargin{1}) && numel(size(varargin{1}))==2 && all(size(varargin{1})==[3,3])     % rlu_corr
    rlu_corr=varargin{1};
    [alatt,angdeg]=rlu_corr_to_lattice(rlu_corr,alatt0,angdeg0);


elseif narg>=1 && narg<=4
    alatt=varargin{1}(:)';  % ensure row vector
    if ~isnumeric(alatt)||numel(alatt)~=3||any(alatt<=0)
        error('HORACE:change_crystal:invalid_argument', ...
            'Check new lattice parameters [a,b,c] are all greater than zero');
    end
    if narg>=2
        angdeg=varargin{2}(:)';     % ensure row vector
        if ~isnumeric(angdeg)||numel(angdeg)~=3||any(angdeg<=0)
            error('HORACE:change_crystal:invalid_argument', ...
                'Check new lattice angles [alf,bet,gam] are all greater than zero');
        end
    else
        angdeg=angdeg0;
    end

    b0 = bmatrix(alatt0,angdeg0);
    b  = bmatrix(alatt,angdeg);

    if narg<=2
        rlu_corr=b\b0;
    elseif narg==3
        rotmat=varargin{3};
        if ~(isnumeric(rotmat) && numel(size(rotmat))==2 && all(size(rotmat)==[3,3]) && abs(det(rotmat)-1)<1e-12)
            error('HORACE:change_crystal:invalid_argument', ...
                'Check rotation matrix is orthogonal with determinant=+1');
        end
        rlu_corr=b\rotmat*b0;
    elseif narg==4
        if ~exist('header','var')|| isempty(header)
            error('HORACE:change_crystal:invalid_argument', ...
                'Alignment vectors u and v are provided, but experiment info, describing initial alignment is missing');
        end
        lattice_parms = struct();
        lattice_parms.alatt = alatt;
        lattice_parms.angdeg = angdeg;
        header_ave=header.header_average(lattice_parms);  % this gets the header for the first spe file that contributed.

        u=varargin{3}(:)';
        v=varargin{4}(:)';
        if (~isnumeric(u)||numel(u)~=3||all(abs(u)<=1e-12)) || (~isnumeric(v)||numel(v)~=3||all(abs(v)<=1e-12))
            error('HORACE:change_crystal:invalid_argument', ...
                'New orientation vectors u and/or v are invalid');
        end
        u0=header_ave.cu;
        v0=header_ave.cv;
        ub0 = ubmatrix(u0,v0,b0);
        ub  = ubmatrix(u,v,b);
        rlu_corr=ub\ub0;
    end


else
    error('HORACE:change_crystal:invalid_argument', ...
        'Incorrect number of input arguments. Should be from 1 to 4');
end
