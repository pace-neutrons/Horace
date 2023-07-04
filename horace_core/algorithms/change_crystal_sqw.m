function out=change_crystal_sqw(filenames,alignment_info)
% Change the crystal lattice and orientation of an sqw object or array of objects
%
% Most commonly:
%   >> wout = change_crystal (w, alignment_info)      % change lattice parameters and orientation
%
% Input:
% -----
%   w           Input sqw object
%
% alignment_info -- class helper containing all information about crystal
%                   realignment, produced by refine_crystal procedure.
%               This matrix can be obtained from refining the lattice and
%              orientation with the function refine_crystal (type
%              >> help refine_crystal  for more details).
% Output:
% -------
%   wout        Output sqw object with changed crystal lattice parameters and orientation
%
% NOTE
%  The input data set(s) can be reset to their original orientation by inverting the
%  input data e.g.
%    - call with inv(rlu_corr)
%    - call with the original alatt, angdeg, u and v

% Original author: T.G.Perring
%


% This routine is also used to change the crystal in sqw files, when it overwrites the input file.

out = change_crystal(filenames,alignment_info);
