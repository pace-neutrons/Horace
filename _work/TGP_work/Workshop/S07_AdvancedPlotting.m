%% ========================================================================
%             Advanced plotting and publication quality figures
% =========================================================================

% NOTE - For help about the syntax of any command, type in Matlab:
% >> help routine_name
%  or
% >> doc routine_name
%
% EXAMPLES
% To prints in the Matlab command window the help for the gen_sqw routine
% >> help gen_sqw
%
% To displays the help for gen_sqw in the Matlab documentation window
% >> doc gen_sqw

clear variables


%% ========================================================================
%                          Two dimensional plot
% =========================================================================
sqw_file = '../aaa_my_work/iron.sqw';

rlp = [1,-1,0; 2,0,0; 1,1,0; 1,-1,0];
wspag = spaghetti_plot(rlp,sqw_file,'qbin',0.1,'qwidth',0.3,'ebin',[0,4,250]);
lz 0 3



%% ========================================================================
%                          Two dimensional plot
% =========================================================================

% Recreate the Q-E slice from earlier, this time without saving the pixel
% information
proj.u  = [1,1,0]; proj.v  = [-1,1,0]; proj.uoffset  = [0,0,0,0]; proj.type  = 'rrr';

my_slice = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], [0,4,280], '-nopix');

% Plot the 2d slice first:
plot(smooth(compact(my_slice)));

% Set limits
lx -2 2
ly 40 250
lz 0 0.5

% Make a nicer title
title('My QE slice');

% Label the axes with something nicer
xlabel('(1+h,-1+h,0) (r.l.u.)');
ylabel('Energy (meV)');

% Get rid of the colour slider
colorslider('delete');
colorbar

% If we want to set the font sizes to be bigger, then we have to re-do the
% above:
title('My QE slice', 'FontSize', 16);
xlabel('(1+h,-1+h,0) (r.l.u.)', 'FontSize', 16);
ylabel('Energy (meV)', 'FontSize', 16);

% To set the font size of the ticks, we need to access the figure's axes.
my_handles = get(gca)
% there are many things you can adjust! To set the font size, or any of the
% other properties, do the following:
set(gca, 'FontSize', 16);

% Suppose we want to change what tick marks are used on the x-axis
set(gca, 'XTick', -2:0.5:2);
set(gca, 'XTickLabel', arrayfun(@num2str, -2:0.5:2, 'UniformOutput', false));

%Put some text on the figure:
text(-0.5, 220, 'Ei = 400 meV', 'FontSize', 16);

% Some fancier text to label the colour bar:
tt = text(3.2, 240, 'Intensity (mb sr^{-1} meV^{-1} f.u.^{-1})', 'FontSize', 16);
set(tt, 'Rotation', -90)

%Save as jpg and eps
print('-djpeg', '../aaa_my_work/figure.jpg');
print('-depsc', '../aaa_my_work/figure.eps');


%% ========================================================================
%                          One dimensional plots
% =========================================================================

% Make an array of 1d cuts:
energy_range = [80:20:160];
for i = 1:numel(energy_range)
    my_cuts(i) = cut_sqw(sqw_file, proj, [-3,0.05,3], [-1.1,-0.9], [-0.1,0.1], ...
        [-10 10]+energy_range(i));
end

% plot them individually, to see what they look like first
for i = 1:numel(energy_range)
    plot(my_cuts(i)); keep_figure;
end

% We want to plot them all on the same axes, with different colours and
% markers.
my_col={'black','red','blue','green','yellow'};
my_mark={'+', 'o', '*', '.', 'x', 's', 'd', '^', 'v', '>', '<', 'p', 'h'};
% note the above are all the possible choices!

for i = 1:numel(my_cuts)
    acolor(my_col{i})
    amark(my_mark{i});
    if i==1
        plot(my_cuts(i));
    else
        % The pp command overplots (markers and errorbars) on existing 1d axes
        pp(my_cuts(i));
    end
end

% This is a bit messy. Let's add a constant offset between each cut, and make
% the markers bigger
my_offset=[0:0.3:1.2];
for i = 1:numel(my_cuts)
    acolor(my_col{i})
    amark(my_mark{i},6);
    if i==1
        plot(my_cuts(i) + my_offset(i));
    else
        pp(my_cuts(i) + my_offset(i));
    end
end

% But we could have done this much more cleanly using the vectorised capabilities
% of Horace functions
acolor({'black','red','blue','green','yellow'})
amark({'+', 'o', '*', '.', 'x', 's'},6)
my_cut_offset = my_cuts + [0:0.3:1.2];
dp(my_cut_offset)


% Now need to extend axes to see everything:
lx -2 2
ly 0 1.8

% Use the same settings as before to get nice font sizes
title('Q cuts', 'FontSize', 16);
xlabel('(1+h,-1+h,0) (r.l.u.)', 'FontSize', 16);
ylabel('Intensity (mb sr^{-1} meV ^{-1} f.u.^{-1})', 'FontSize', 16);
set(gca, 'FontSize', 16);
set(gca, 'XTick', -2:0.5:2);
set(gca, 'XTickLabel', arrayfun(@num2str, -2:0.5:2, 'UniformOutput', false));

% Insert a figure legend
legend('80 meV','100 meV','120 meV', '140 meV','160 meV');

% But this is wrong!!! This is a peculiarity of Horace, in that it plots the
% markers then the errorbars, and Matlab doesn't keep track of this. Luckily
% there is a workaround, by getting a "handle" to each plot and then
% attaching the legend to that.

for i = 1:numel(my_cuts)
    acolor(my_col{i})
    amark(my_mark{i},8);
    if i==1
        [fig_handle, axes_handle, plot_handle] = plot(my_cuts(i) + my_offset(i));
    else
        [fig_handle, axes_handle, plot_handle] = pp(my_cuts(i) + my_offset(i));
    end
end
lx -2 2
ly 0 1.8

legend(plot_handle([10,8,6,4,2]), ...
       {'80 meV','100 meV','120 meV', '140 meV','160 meV'}, ...
       'Location','NorthWest');

% You can also manually edit the plot, using the arrow tool to highlight
% part of the plot you want to change. e.g. you can remove the box around
% the legend by setting its colour to be white

