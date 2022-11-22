function varargout=set_mod_pulse_horace(varargin)
% Set the moderator pulse shape model and pulse parameters for an array of sqw objects.
%
%   >> wout = set_mod_pulse(file, pulse_model, pp)
%
% Input:
% ------
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%   pulse_model Pulse shape model name e.g. 'ikcarp'
%   pp          Pulse shape parameters: row vector for a single set of parameters
%              or a 2D array, one row per spe data set in the sqw object(s).


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
%
% Output:
% -------
%   wout        Output sqw objects


% Original author: T.G.Perring
%

out = set_mod_pulse(varargin);
for i=1:nargout
    varargout{i} = out{i};
end
