function wout = change_crystal (obj,alignment_info,varargin)
% Change the crystal lattice and orientation of an sqw object or array of objects
%
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
%   wout        Output sqw object with changed crystal lattice parameters
%               and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by
%  nullifying alignment matrix in PixelData class and setting lattice
%  parameters to their initial values

% This routine is also used to change the crystal in sqw files, when it overwrites the input file.

if ~isa(alignment_info,'crystal_alignment_info') || nargin>2
    error('HORACE:sqw:invalid_argument',...
        ['Old interface to modify the crystal alignment is deprecated.\n', ...
        ' Use crystal_alignment_info object obtained from "refine_crystal" routine to realign crystal.\n', ...
        ' Call >>help refine_crystal for the details']);
end


% Perform operations
% ------------------
wout = obj;
alignment_mat = alignment_info.rotmat;
for i=1:numel(obj)
    proj = obj(i).data.proj;    % unmodified projection to change
    if ~isempty(proj.ub_inv_legacy)
        alignment_info.legacy_mode = true;
    end
    wout(i).data = obj(i).data.change_crystal(alignment_info);
    wout(i).experiment_info = obj(i).experiment_info.change_crystal(alignment_info,proj);
    %
    if ~alignment_info.legacy_mode
        % this invalidates q-range of pixels for filebacked pixels and
        % recalculates it for memory-based pixels
        wout(i).pix.alignment_matr = alignment_mat;
    end
end
