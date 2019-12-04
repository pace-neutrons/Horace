function [header_ave, ebins_all_same]=header_average(sqw)
% Get average header information from header field of sqw object
%
% *** Assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines

[header_ave, ebins_all_same] = header_average(sqw.header);
