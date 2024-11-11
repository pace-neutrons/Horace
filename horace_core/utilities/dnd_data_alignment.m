function [al_info,dnd_obj] = dnd_data_alignment(dnd_obj,hav)
% Get  alignment information from dnd object and IX_experiment -- Horace-3
% implementation. If requested, realign dnd object using this information.
%
% It is assumed that IX_experiment contains legacy alignment information
% and the routine extracts this information and converts it into modern
% alignment format.
%
% Inputs:
% dnd_obj -- dnd object to align
% hav     -- representative instance of IX_experiment as used in Horace-3
%            or structure retrieved from IX_experiment, in particular by
%            using Experiment.header_average.
% Returns:
% al_info -- instance of crystal_alignment_info class containing rotation
%            matrix used in dnd object alignment
% Optional:
% dnd_obj -- aligned dnd object
%
if (isfield(hav,'u_to_rlu')||isprop(hav,'u_to_rlu')) && ~isempty(hav.u_to_rlu)
    proj = dnd_obj.proj;
    alignment_matrix = proj.bmatrix(4)*hav.u_to_rlu;
else
    alignment_matrix= eye(2);
end

if any(abs(subdiag_elements(alignment_matrix))>4*eps('single'))
    % legacy files do not have correct aligned projection
    rotvec = rotmat_to_rotvec_rad(alignment_matrix(1:3,1:3));
    al_info = crystal_alignment_info(dnd_obj.alatt,dnd_obj.angdeg,rotvec);
    if nargout>1
        dnd_obj = dnd_obj.change_crystal(al_info);
    end
else
    %dnd_obj.proj = proj.get_line_proj();
    al_info = [];
end
