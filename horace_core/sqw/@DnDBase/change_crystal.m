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


if ~isa(alignment_info,'crystal_alignment_info')
    error('HORACE:DnDBase:invalid_argument',...
        ['Old interface to modify the crystal alignment is deprecated.\n', ...
        ' Use crystal_alignment_info class obtained from "refine_crystal" routine to realign crystal.\n', ...
        ' Call >>help refine_crystal for the details']);
end


wout = obj;

for i=1:numel(obj)
    legacy_mode = alignment_info.hkl_mode;
    this_alignment = alignment_info;
    if isa(wout(i).proj,'line_proj_interface')
        proj = wout(i).proj;
    else
        error('HORACE:DnDBase:invalid_argument',...
            ['Alignment is possible for objects with coordinate systems defined line_proj only.\n' ...
            ' Object N%d coordinates defined by: %s projection'], ...
            i,class(wout(i).proj))
    end


    if legacy_mode
        this_alignment.hkl_mode  = true;
        proj = proj.get_ubmat_proj();
    end
    [wout(i).proj,wout(i).axes] = proj.align_proj(alignment_info,wout(i).axes);
end
