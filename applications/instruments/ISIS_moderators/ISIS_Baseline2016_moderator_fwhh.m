function w_fwhh = ISIS_Baseline2016_moderator_fwhh(modStruct,en)
% Get FWHH of moderator pulse
%
%   >> w_fwhh = ISIS_Baseline2016_moderator_fwhh (source)      % at raw data energy bin centres
%   >> w_fwhh = ISIS_Baseline2016_moderator_fwhh (source, en)
%
% Input:
% ------
%   source      Moderator file (.mat file), or structure as loaded from
%               a moderator .mat file by the function ISIS_Baseline2016_moderator_load
%
%   en          Array of energies (meV)
%               Default: the energy bin centres of the data in modStruct
%
% Output:
% -------
%   w_fwhh      IX_dataset_1d object with fwhh (meV) as a function energy


if ischar(modStruct)
    modStruct = ISIS_Baseline2016_moderator_load (modStruct);
end

if nargin==1
    en = modStruct.encent;
end

w = zeros(size(en));
for i=1:numel(en)
    [t, y] = ISIS_Baseline2016_moderator_time_profile (modStruct, en(i));
    [~,~,w(i)]=peak_cwhh_xye(t,y,zeros(size(y)),0.5);
end

w_fwhh = IX_dataset_1d(en(:),w(:));
