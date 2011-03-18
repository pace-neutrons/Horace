function genieplot_init
% Initialise graphics

% Initialise graphics styles
genieplot.color{1} = 'k';
genieplot.line_style{1} = '-';
genieplot.line_width = 0.5;
genieplot.marker_type{1} = 'o';
genieplot.marker_size = 6;
genieplot.xscale = 'linear';
genieplot.yscale = 'linear';

set_global_var('genieplot',genieplot)
