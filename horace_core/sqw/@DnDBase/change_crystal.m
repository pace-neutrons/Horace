function wout = change_crystal(obj,alignment_info,varargin)
% Change the crystal lattice and orientation of an dnd object or array of objects
%
%   >> obj=change_crystal(obj,alignment_info)
% Input:
% -----
%   w           Input sqw object or array of sqw objects
%
%   >> obj=change_crystal(obj,alignment_info)
%
% obj            -- initialized instance of Experiment object
%
% alignment_info -- helper class, containing the information
%                   about the crystal alignment, returned by refine_crystal
%                   routine. Type:
%                  >> help refine_crystal  for more details.
%
% Output:
% -------
%   wout        Output dnd object with changed crystal lattice parameters and orientation

if ~isa(alignment_info,'crystal_alignment_info') || nargin>2
    error('HORACE:DnDBase:invalid_argument',...
        ['Old interface to modify the crystal alighnment is deprecated.\n', ...
        ' Use crystal_alignment_info class obtained from "refine_crystal" routine to realign crystal.\n', ...
        ' Call >>help refine_crystal for the details']);
end


wout = obj;

alatt  = alignment_info.alatt;
angdeg = alignment_info.angdeg;
for i=1:numel(obj)
    legacy_mode = alignment_info.legacy_mode || ~isempty(obj.proj.ub_inv_legacy);    
    if legacy_mode
        this_alignment = alignment_info;
        this_alignment.legacy_mode  = true;
        rlu_corr = this_alignment.get_corr_mat(obj.proj);        
        u_to_rlu = wout(i).proj.u_to_rlu;
        wout(i).offset(1:3)=rlu_corr*wout(i).offset(1:3)';
        wout(i).proj = wout(i).proj.set_ub_inv_compat(rlu_corr*u_to_rlu(1:3,1:3));        
    end
    wout(i).alatt=alatt;
    wout(i).angdeg=angdeg;    
end
