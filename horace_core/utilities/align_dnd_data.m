function [dnd_obj,al_info] = align_dnd_data(dnd_obj,hav)
% Alighn dnd data using aligmmnet information stored in legacy IX_experiment 
%
% Inputs:
% dnd_obj -- dnd object to align
% hav     -- representative instance of IX_experiment or srtucture retrieved
%            from IX_experiment, in particular by using
%            Experiment.header_average
% Returns:
% dnd_obj -- aligned dnd object
% al_info -- instance of crystal_alignment_info class containing rotation
%            matrix used in dnd object alignment
%
proj = dnd_obj.proj;
if (isfield(hav,'u_to_rlu')||isprop(hav,'u_to_rlu')) && ~isempty(hav.u_to_rlu)
    alignment_matrix = proj.bmatrix(4)*hav.u_to_rlu;
else
    alignment_matrix= eye(2);
end

if any(abs(subdiag_elements(alignment_matrix))>4*eps('single'))
    % legacy files do not have correct aligned projection
    rotvec = rotmat_to_rotvec2(alignment_matrix(1:3,1:3));
    al_info = crystal_alignment_info(dnd_obj.alatt,dnd_obj.angdeg,rotvec);
    dnd_obj = dnd_obj.change_crystal(al_info);
else
    %dnd_obj.proj = proj.get_line_proj();
    al_info = [];
end
