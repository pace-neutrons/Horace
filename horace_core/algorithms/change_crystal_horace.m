function varargout=change_crystal_horace(varargin)
% Change the crystal lattice and orientation of an sqw object stored in a file
% or celarray of files
%
%   >> change_crystal_horace(filenames, alignment_info) % change lattice parameters and orientation
%                                                 % of the crystal according to the
%                                                 % crystal alignment information provided
%
%
% Input:
% -----
%   w           Input sqw object, filename or list of filenames or sqw
%               objects
%
% alignment_info -- class helper containing all information about crystal
%                   realignment, produced by refine_crystal procedure.
%
%              do:
%              >> help refine_crystal  for more details.
%
% Output:
% -------
%   out        Output sqw/dnd object with changed crystal lattice parameters
%              and pixels orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data i.e. providing alignment_info with original alatt and angdeg
%  and rotvec describing 3-D rotation in the direction opposite to initial
%  direction. (rovect_inv = -rotvec_alignment)

% Original author: T.G.Perring
%
%
if nargout>0
    if numel(varargin{1}) == nargout
        out = change_crystal(varargin{:});
        for i=1:nargout
            varargout{i} = out{i};
        end
    else
        varargout{1} = change_crystal(varargin{:});
    end
else
    change_crystal(varargin{:});
end