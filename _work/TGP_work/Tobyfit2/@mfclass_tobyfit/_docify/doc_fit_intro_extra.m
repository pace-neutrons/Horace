% Additional return arguments if refining moderator or crystal orientation
%
% Crystal orientation:
%   >> [data_out, fitdata, ok, mess, rlu_corr] = obj.fit (...)
%
%   rlu_corr is the reorientation matrix used by to change crystal
%   orientation. See:
%   <a href="matlab:doc sqw/change_crystal">mfclass/change_crystal</a>
%   <a href="matlab:doc change_crystal_horace">mfclass/change_crystal_horace</a>
%   <a href="matlab:doc change_crystal_sqw">mfclass/change_crystal_sqw</a>
%   <a href="matlab:doc change_crystal_dnd">mfclass/change_crystal_dnd</a>
%
% Moderator refinement:
%   >> [data_out, fitdata, ok, mess, pulse_model, p, psig] = obj.fit (...)
%   pulse_model and p are the parameters used by set_mod_pulse. See:
%   <a href="matlab:doc sqw/get_mod_pulse">mfclass/get_mod_pulse</a>
%   <a href="matlab:doc get_mod_pulse_horace">mfclass/get_mod_pulse_horace</a>
%   <a href="matlab:doc sqw/set_mod_pulse">mfclass/set_mod_pulse</a>
%   <a href="matlab:doc set_mod_pulse_horace">mfclass/set_mod_pulse_horace</a>
