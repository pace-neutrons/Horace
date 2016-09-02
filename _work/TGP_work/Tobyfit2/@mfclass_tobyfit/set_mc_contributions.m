function obj = set_mc_contributions (obj, varargin)
% Set the ocomponents that contribute to the resolution function
%
% Set default (all contributions):
%   >> obj = obj.set_mc_contributions
%
% Set all contributions or no contributions:
%   >> obj = obj.set_mc_contributions ('all')    % all contributions
%   >> obj = obj.set_mc_contributions ('none')   % no contributions
%
% All components included except...
%   >> obj = obj.set_mc_contributions ('nomoderator')
%   >> obj = obj.set_mc_contributions ('nomoderator','nochopper')
%
% Only include...
%   >> obj = obj.set_mc_contributions ('chopper','sample')


[mc_contributions,ok,mess] = mc_contributions_parse (varargin{:});
if ok
    obj.mc_contributions_ = mc_contributions;
else
    error(mess)
end
