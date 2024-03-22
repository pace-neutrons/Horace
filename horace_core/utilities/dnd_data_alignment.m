function [al_info,dnd_obj] = dnd_data_alignment(dnd_obj,hav)
% Get alignment information from dnd object and IX_experiment. 
% if requested, realign dnd object using this information.
%
% Inputs:
% dnd_obj -- dnd object to align
% hav     -- representative instance of IX_experiment or structure retrieved
%            from IX_experiment, in particular by using
%            Experiment.header_average
% Returns:
% dnd_obj -- aligned dnd object
% al_info -- instance of crystal_alignment_info class containing rotation
%            matrix used in dnd object alignment
%
if (isfield(hav,'u_to_rlu')||isprop(hav,'u_to_rlu')) && ~isempty(hav.u_to_rlu)
    proj = dnd_obj.proj;    
    alignment_matrix = proj.bmatrix(4)*hav.u_to_rlu;
else
    alignment_matrix= eye(2);
end

if any(abs(subdiag_elements(alignment_matrix))>4*eps('single'))
    % legacy files do not have correct aligned projection
    rotvec = rotmat_to_rotvec2(alignment_matrix(1:3,1:3));
    al_info = crystal_alignment_info(dnd_obj.alatt,dnd_obj.angdeg,rotvec);
    if nargout>1
        dnd_obj = dnd_obj.change_crystal(al_info);
    end
else
    %dnd_obj.proj = proj.get_line_proj();
    al_info = [];
end
