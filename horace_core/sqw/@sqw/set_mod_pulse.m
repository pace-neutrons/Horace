function obj = set_mod_pulse(obj,pulse_model,pm_par)
% Set the moderator pulse shape model and pulse parameters for an array of sqw objects.
%
%   >> obj = set_mod_pulse(obj, pulse_model, pp)
%
% Input:
% ------
%   obj         Array of sqw objects of sqw type
%   pulse_model Pulse shape model name e.g. 'ikcarp'
%   pm_par      Pulse shape parameters: row vector for a single set of parameters
%               or a 2D array, one row per spe data set in the sqw object(s).
%
% Output:
% -------
%   obj        Output sqw objects


% Original author: T.G.Perring
%


for i=1:numel(obj)
    obj(i).experiment_info = obj(i).experiment_info.set_mod_pulse( ...
        pulse_model,pm_par);
end