function set_efix_horace(files,varargin)
% Set the fixed neutron energy for an array of sqw objects.
%
%   >> set_efix(file, efix)
%   >> set_efix(file, efix, emode)
%
% Input:
% ------
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%   efix        Value or array of values of efix. If an array, all sqw
%              objects must have the same number of contributing spe data sets
%   emode       [Optional] Energy mode: 1=direct inelastic, 2=indirect inelastic, 0=elastic


% Original author: T.G.Perring
%
set_efix(files,varargin{:});