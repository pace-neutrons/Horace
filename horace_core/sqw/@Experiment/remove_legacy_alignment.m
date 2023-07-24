function obj=remove_legacy_alignment(obj,al_info)
% REMOVE_LEGACY_ALIGNMENT Change fields in the experiment with correction
% to remove legacy alignment applied to the crystal earlier.
%
%
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% Optional
% alatt   -- lattice parameters with new values for lattice. (presumably
%            before alignment)
% angdeg  -- lattice angles with values necessary to set.
%            Of one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed.
% Outputs:
% wout    -- dealigned dnd object
% al_info -- instance of crystal_alignment_info class, containing alignment
%            parameters, used to do legacy alignment.

%
sam = obj.samples;
exper = obj.expdata;
alatt = al_info.alatt;
angdeg = al_info.angdeg;
al_info.hkl_mode = true;
% define rotation in opposite direction, to compencate for previous
% alignment
al_info.rotvec = -al_info.rotvec;

for i=1:obj.n_runs
    s = sam{i};
    alatt0 = s.alatt;
    angdeg0 = s.angdeg;
    s.alatt=alatt;
    s.angdeg=angdeg;
    sam{i} = s;

    rlu_corr = al_info.get_corr_mat(alatt0,angdeg0);

    exper(i).cu=(rlu_corr*exper(i).cu')';
    exper(i).cv=(rlu_corr*exper(i).cv')';
    exper(i).uoffset(1:3)=rlu_corr*exper(i).uoffset(1:3);
    exper(i).u_to_rlu(1:3,1:3)=rlu_corr*exper(i).u_to_rlu(1:3,1:3);
end
obj.samples = sam;
obj.expdata = exper;
