function [obj,deal_info,no_alignment] = upgrade_legacy_alignment(obj,u_to_rlu_instr,varargin)
%UPDATE_LEGACY_ALIGNMENT:  modify crystal lattice and orientation matrix
% to remove legacy alignment applied to the crystal earlier and place
% changes related to current alignment instead
%
% Inputs:
% obj    -- legacy realigned dnd object. Algorithm does nothing if the
%           object has not been aligned using legacy algorithm.
% u_to_rlu_instr
%        -- u_to_rlu stored with IX_experiment. It is recovered only if
%           it is rotmat*inv(b_matrix), i.e. it has any under-diagonal elements;
% Optional
% alatt   -- lattice parameters with old values for lattice. (before alignment)
% angdeg  -- lattice angles with old values for lattice angles (before alignment).
%  IMPORTANT:
%            Of one is present, another one have to be present.
%            If these values are missing, assumes that the lattice have not
%            been changed, but if it has in fact been changed, upgrade
%            would not be  correct.
% Outputs:
% obj     -- realigned according to modern algorithm instance of input dnd
%            object or unchanged input object it legacy alignment has not
%            been identified.
% al_info -- instance of crystal_alignment_info class, containing alignment
%            parameters, used to do legacy alignment.
% no_alignment
%          -- true if no legacy alignment was identified on the object
%
% Does nothing if identified that crystal has not been legacy realigned
%
alatt_al     = obj.alatt;
angdeg_al    = obj.angdeg;
if isempty(u_to_rlu_instr)
    no_alignment  = true;
    deal_info = crystal_alignment_info(alatt_al,angdeg_al,zeros(1,3));
    return;
end
no_alignment = false;
try
    [obj,deal_info] = remove_legacy_alignment(obj,u_to_rlu_instr,varargin{:});
catch ME
    if strcmp(ME.identifier,'HORACE:DnDBase:invalid_argument') && ...
            contains(ME.message,'Nothing to do')
        no_alignment  = true;
        return
    else
        rethrow(ME);
    end
end

al_info = crystal_alignment_info(alatt_al,angdeg_al,-deal_info.rotvec);
obj = obj.change_crystal(al_info);
obj.proj = obj.proj.get_line_proj();
