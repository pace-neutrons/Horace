function obj=remove_legacy_alignment(obj,deal_info)
% REMOVE_LEGACY_ALIGNMENT Change fields in the experiment with correction
% to remove legacy alignment applied to the crystal earlier.
%
%
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm throws if the object has
%           not been realigned using legacy algorithm.
% deal_info 
%       -- instance of crystal_alignment_info class, containing information
%          about de-alignment
%
% Outputs:
% obj     -- Experiment object with alignment removed

%
sam = obj.samples;
exper = obj.expdata;
alatt0  = deal_info.alatt;
angdeg0 = deal_info.angdeg;
deal_info.hkl_mode = true;


for i=1:obj.n_runs
    s = sam{i};
    alatt_al  = s.alatt;
    angdeg_al = s.angdeg;
    s.alatt=alatt0;
    s.angdeg=angdeg0;
    sam{i} = s;

    rlu_corr = deal_info.get_corr_mat(alatt_al,angdeg_al);

    exper(i).cu=(rlu_corr*exper(i).cu')';
    exper(i).cv=(rlu_corr*exper(i).cv')';
    off = exper(i).uoffset(1:3);
    exper(i).uoffset(1:3)=rlu_corr*off(:);
    exper(i).u_to_rlu(1:3,1:3)=rlu_corr*exper(i).u_to_rlu(1:3,1:3);
end
obj.samples = sam;
obj.expdata = exper;
