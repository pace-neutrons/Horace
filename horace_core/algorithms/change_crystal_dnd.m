function varargout = change_crystal_dnd(varargin)
% Change the crystal lattice and orientation of dnd objects or
% dnd objects stored in a file or celarray of files
%
% Usage:
%   >>change_crystal (in_data, alignment_info,varargin);
%   >>out = change_crystal (in_data, alignment_info,varargin);
%
%
% Input:
% -----
% in_data        --  Input sqw object, cellarray of sqw/dnd objects or
%                     cellarray of files containing sqw/dnd objects.
%
% alignment_info -- class helper containing all information about crystal
%                   realignment, produced by refine_crystal procedure.
%
%              do:
%              >> help refine_crystal  for more details.
%
% Output:
% -------
%   varargout  Output sqw object with changed crystal lattice parameters and orientation
%              or cellarray contaning such objects or set of sqw objects or
%              sqw files%
%
%  Algorithm will fail if applied to .sqw files containing full sqw
%  objects, not dnd objects
%
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data i.e. providing alignment_info with original alatt and angdeg
%  and rotvec describing 3-D rotation in the direction opposite to initial
%  direction. (rovect_inv = -rotvec_alignment)
%
% Original author: T.G.Perring
%
%
argi = [varargin(:);'-dnd_only'];
if nargout>0
    if numel(argi{1}) == nargout
        out = change_crystal(argi{:});
        for i=1:nargout
            varargout{i} = out(i);
        end
    else
        varargout{1} = change_crystal(argi{:});
    end
else
    change_crystal(argi{:});
end