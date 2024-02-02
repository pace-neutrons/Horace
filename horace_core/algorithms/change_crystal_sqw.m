function varargout=change_crystal_sqw(filenames,alignment_info)
% Change the crystal lattice and orientation of an sqw/dnd objects or
% sqw/dnd object  stored in a file or celarray of files
%
% Usage:
%   >>change_crystal (in_data, alignment_info,varargin);
%   >>out = change_crystal (in_data, alignment_info,varargin);
%
%
% Input:
% -----
%  in_data       --  Input sqw object, cellarray of sqw/dnd objects or
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
%   out        Output sqw object with changed crystal lattice parameters and orientation
%              or cellarray contaning such objects.
%
%  Throws error if dnd object or dnd file is provided as input for
%  alignment
%
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data i.e. providing alignment_info with original alatt and angdeg
%  and rotvec describing 3-D rotation in the direction opposite to initial
%  direction. (rovect_inv = -rotvec_alignment)
%

% Original author: T.G.Perring


argi = {filenames,alignment_info,'-sqw_only'};
if nargout>0
    if numel(varargin{1}) == nargout
        out = change_crystal(argi{:});
        for i=1:nargout
            varargout{i} = out{i};
        end
    else
        varargout{1} = change_crystal(argi{:});
    end
else
    change_crystal(argi{:});
end