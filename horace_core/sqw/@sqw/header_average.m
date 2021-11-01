function [header_ave, ebins_all_same]=header_average(obj)
% Get average header information from header field of sqw object
%
% *** Assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines


[header_ave, ebins_all_same] = header_average_(obj.experiment_info,nargout);

function [header_ave, ebins_all_same]=header_average_(exper_info,narg)
% Get average header information from header field of sqw object
%
% *** Assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines

header_ave = exper_info.get_aver_experiment();

if narg == 1   % requested average header
    ebins_all_same = [];
    return;
end
ebins_all_same = exper_info.is_same_ebins();