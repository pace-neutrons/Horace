function varargout=change_crystal_horace(varargin)
% Legacy call to change_crystal algorithm. 
%
% Change the crystal lattice and orientation of sqw/dnd object or objects
% placed in various type of containers.
%
% Usage:
%   >>change_crystal_horace(in_data, alignment_info,varargin);
%   >>out = change_crystal_horace(in_data, alignment_info,varargin);
%
%
% Input:
% -----
%  in_data       --  Input sqw.dnd object, cellarray of sqw/dnd objects or
%                    filename or cellarray of filenames containing sqw/dnd
%                    objects.
%
% alignment_info -- crystal_alignment_info class -- helper containing all
%                   information about crystal realignment, produced by
%                   refine_crystal procedure.
%
%              do:
%              >> help refine_crystal
%              or
%              >> help crystal_alignment_info
%              for more details.
% Optional:
% '-dnd_only'   -- Align only dnd object, so will work on files
%                  or cellarray of objects contaning dnd objects only.
%                  Algorithm will fail if applied to .sqw files or cellarrays
%                  containing sqw objects.
% '-sqw_only'   -- align only sqw objects or files containing sqw objects.
%                  Throw error if dnd object (as member of cellarray) or
%                  dnd object in .sqw file is provided as input.
%
% Output:
% -------
%   out        Output sqw object with changed crystal lattice parameters and orientation
%              or cellarray contaning such objects.
%              Must be provided if input contains filebacked sqw objects.
%
% NOTE
%  The input data set(s) can be reset to their original orientation by
%  providing input data which correspond to aligingment to initial state
%  i.e. providing 'crystl_alignment_info' with original alatt and angdeg
%  and rotvec describing 3-D rotation in the direction opposite to the
%  alignment direction i.e. rovect_inv = -rotvec_alignment.
%

% Original author: T.G.Perring
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