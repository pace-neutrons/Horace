function genieplot_init
% Initialise graphics

% Initialise graphics styles
genieplot.color{1} = 'k';

genieplot.line_style{1} = '-';
genieplot.line_styles = {'-','--',':','-.'};
genieplot.line_width = 0.5;
genieplot.marker_type{1} = 'o';
genieplot.marker_size = 6;
genieplot.xscale = 'linear';
genieplot.yscale = 'linear';
genieplot.zscale = 'linear';

if verLessThan('MATLAB','9.9')
    genieplot.colors = {'r','g','b','c','m','k'};
    genieplot.marker_types = {'o','+','*','.','x','s','d','^','v','>','<','p','h'};    
else
    genieplot.colors = {'r','g','b','c','m','k','#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
    genieplot.marker_types = {'o','+','*','.','x','_','|','square','diamond','^','v','>','<','pentagram','hexagram'};
end


genieplot.oned_maxspec = 1000;
genieplot.oned_binning = 1;

genieplot.twod_maxspec = 1000;
genieplot.twod_nsmooth = 0;

% Initialise default figure names
genieplot.name_oned = 'Herbert 1D plot';
genieplot.name_multiplot = 'Herbert multiplot';
genieplot.name_stem = 'Herbert stem plot';
genieplot.name_area = 'Herbert area plot';
genieplot.name_surface = 'Herbert surface plot';
genieplot.name_contour = 'Herbert contour plot';
genieplot.name_sliceomatic = 'Sliceomatic';

% Set global variable
set_global_var('genieplot',genieplot)


