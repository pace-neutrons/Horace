%
% Additional return arguments if refining moderator or crystal orientation:
% -------------------------------------------------------------------------
% Crystal orientation:
%   If crystal refinement has been set (see <a href="matlab:help('mfclass_tobyfit/set_refine_crystal');">set_refine_crystal</a>):
%
%   >> [data_out, fitdata, ok, mess, rlu_corr] = obj.fit (...)
%
%   rlu_corr    Reorientation matrix used to change crystal orientation.
%
%   See:
%   <a href="matlab:help sqw/change_crystal">mfclass/change_crystal</a>
%   <a href="matlab:help change_crystal_horace">mfclass/change_crystal_horace</a>
%   <a href="matlab:help change_crystal_sqw">mfclass/change_crystal_sqw</a>
%   <a href="matlab:help change_crystal_dnd">mfclass/change_crystal_dnd</a>
%
% Moderator refinement:
%   If moderator refinement has been set (see <a href="matlab:help('mfclass_tobyfit/set_refine_moderator');">set_refine_moderator</a>):
%
%   >> [data_out, fitdata, ok, mess, pulse_model, p, psig] = obj.fit (...)
%
%   pulse_model, p, psig    Refined moderator parameters (and standard errors)
%                          used as input by set_mod_pulse to reset the 
%                          moderator parameters in an sqw object or file.
%   See:
%   <a href="matlab:help sqw/get_mod_pulse">mfclass/get_mod_pulse</a>
%   <a href="matlab:help get_mod_pulse_horace">mfclass/get_mod_pulse_horace</a>
%   <a href="matlab:help sqw/set_mod_pulse">mfclass/set_mod_pulse</a>
%   <a href="matlab:help set_mod_pulse_horace">mfclass/set_mod_pulse_horace</a>
