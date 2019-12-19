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
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)

if nargin<1 || nargin>3
    error('Check number of input arguments')
elseif nargout>0
    error('No output arguments returned by this function')
end

[varargout,mess] = horace_function_call_method (nargout, @set_mod_pulse, '$hor', varargin{:});
if ~isempty(mess), error(mess), end

