function varargout=change_crystal_sqw(in_data,alignment_info)
% Change the crystal lattice and orientation of an sqw object(s) or
% sqw object(s)  stored in a file or celarray of files
%
% Usage:
%   >>change_crystal_sqw (in_data, alignment_info);
%   >>out = change_crystal_sqw(in_data, alignment_info);
%
%
% Input:
% -----
%  in_data       --  Input sqw object, cellarray of sqw objects or
%                    cellarray of files containing sqw objects.
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
%
% Output:
% -------
%   out        Output sqw object with changed crystal lattice parameters 
%              and orientation or cellarray contaning such objects.
%              Must be provided if input contains filebacked sqw objects.
%
%  Algorithm will fail if applied to cellarray containing .sqw files
%  with dnd objects only or dnd objects themselves.
%
%
% NOTE
%  The input data set(s) can be reset to their original orientation by
%  providing input data which correspond to aligingment to initial state
%  i.e. providing 'crystl_alignment_info' with original alatt and angdeg
%  and rotvec describing 3-D rotation in the direction opposite to the
%  alignment direction i.e. rovect_inv = -rotvec_alignment.
%

% Original author: T.G.Perring


argi = {in_data,alignment_info,'-sqw_only'};
if nargout>0
    if numel(argi{1}) == nargout
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