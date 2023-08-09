function obj=change_crystal(obj,alignment_info,proj)
%  Change fields in the experiment with correction related to change crystal
%  lattice parameters and orientation
%
%   >> obj=change_crystal(obj,alignment_info)
%
% obj            -- initialized instance of Experiment object
%
% alignment_info -- helper class, containing the information
%                   about the crystal alignment, returned by refine_crystal
%                   routine. Type:
%                  >> help refine_crystal  for more details.
% proj            -- the instance of the projection, which converts pixels
%                   from

% Change fields of Experiment as required

%
sam = obj.samples;
exper = obj.expdata;
alatt = alignment_info.alatt;
angdeg = alignment_info.angdeg;
compat_mode = alignment_info.hkl_mode;
if compat_mode
    rlu_corr = alignment_info.get_corr_mat(proj);
end
for i=1:obj.n_runs
    s = sam{i};
    alatt0 = s.alatt;
    angdeg0 = s.angdeg;
    s.alatt=alatt;
    s.angdeg=angdeg;
    sam{i} = s;
    if compat_mode % the mode which produces alignment using rlu_correction
        % rather then Crystal Cartesian alignment matrix. Used for tests
        % only
        exper(i).cu=(rlu_corr*exper(i).cu')';
        exper(i).cv=(rlu_corr*exper(i).cv')';
        off = exper(i).uoffset(1:3);
        exper(i).uoffset(1:3)=rlu_corr*off(:);
        exper(i).u_to_rlu(1:3,1:3)=rlu_corr/(bmatrix(alatt0,angdeg0));
    else
        exper(i).angular_units = 'deg';
        [alatt, angdeg, dpsi_deg, gl_deg, gs_deg] = crystal_pars_correct(...
            exper(i).cu, exper(i).cv, alatt0, angdeg0, ...
            exper(i).omega, exper(i).dpsi, exper(i).gl, exper(i).gs,...
            alignment_info);
        exper(i).dpsi = dpsi_deg;
        exper(i).gl   = gl_deg;
        exper(i).gs   = gs_deg;
        exper(i).angular_units = 'rad';
    end
end
obj.samples = sam;
obj.expdata = exper;
