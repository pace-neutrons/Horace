function [header_ave, ebins_all_same]=header_average(obj)
% Get average header information from header field of sqw object
%
% *** Assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines


if nargout>1
    [header_ave, ebins_all_same] = obj.experiment_info.header_average();
else
    
    header_ave = obj.experiment_info.header_average();
    ebins_all_same = [];
end