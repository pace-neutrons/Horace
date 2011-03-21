function [] = logy
% logy  change the y-axis to logarithmic for MGENIE plots
%
global genie_color genie_line_style genie_line_width genie_marker genie_marker_size genie_xscale genie_yscale

% change for future plots
genie_yscale = 'log';

% change current plot
set (gca, 'YScale', genie_yscale);