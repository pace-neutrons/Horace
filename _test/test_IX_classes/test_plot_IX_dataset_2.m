classdef test_plot_IX_dataset_2 < TestCase
    % Test plotting of IX_dataset_1d, IX_dataset_2d and IX_dataset_3d objects
    %
    % These tests have been inspired by problems that have been found during the
    % development of the graphics and user experience to catch unexpected
    % behaviour.
    %
    % They are therefore good tests that the logic of the plotting library has
    % been adhered to in any future refactoring.
    properties
        w1_point
        w1_hist
        w2_point
        w2_hist
        w3_point
        w3_hist
        w2oneD_point_xy
        w2oneD_point_x_hist_y
        w3_unequal
    end
    
    methods
        function obj = test_plot_IX_dataset_2(name)
            obj = obj@TestCase(name);
            
            [obj.w1_point, obj.w1_hist, obj.w2_point, obj.w2_hist, ...
                obj.w3_point, obj.w3_hist, ...
                obj.w2oneD_point_xy, obj.w2oneD_point_x_hist_y, ...
                obj.w3_unequal] = make_data;
        end
        
        %------------------------------------------------------------------
        function test_1D_plotOverCurrent_1D(obj)
            % Plot a 1D IX_dataset over a plot of an IX_dataset_2d (so has a
            % different genie_figure name
            clear_figures()
            cleanupObj = onCleanup(@clear_figures);
            
            [fig_h_ref, axes_h_ref, plot_h_ref] = dl(obj.w1_point(1));
            [fig_h, axes_h, plot_h] = phoc(obj.w1_hist(1));
            assertTrue(fig_h==fig_h_ref, 'New figure created');
            assertTrue(axes_h==axes_h_ref, 'New axes created');
            assertTrue(numel(plot_h)==numel(plot_h_ref)+1, 'Plot missing');
        end
        
        %------------------------------------------------------------------
        function test_1D_axisScale_doesnt_change_if_plotOver(obj)
            % If have plotted 1D data on linear axes, then plot data in a 
            % second window, then issuing >> logx should result in the second
            % figure axes becoming logx (as it is the current figure), but if
            % then make the first genie_figure have 'current' status (in the 
            % genie_figure sense, using >> make_current) and overplotting,
            % the x-axis should remain linear.
            clear_figures()
            cleanupObj = onCleanup(@clear_figures);
            
            % Plot on linear axes
            linx
            [fig1, ax1] = dl(obj.w1_point(1));
            keep_figure
            % New plot
            [~, ax2] = dh(2*obj.w1_point(2));
            logx    % change to log x-axis on the current and subsequent plots
            
            % Make the first figure have genie_figure 'curr' status and plot over
            make_current(fig1)
            [~, is_current] = is_genie_figure (fig1);
            assertTrue(is_current, 'fig1 has ''keep'' status, not ''current'' status')

            ftmp = ph(obj.w1_point(2));
            assertTrue(ftmp==fig1, 'Did not overplot on the first figure')
            assertTrue(isequal(ax1.XScale,'linear'), 'x-axis should be linear but is log')
            assertTrue(isequal(ax2.XScale,'log'), 'x-axis should be log but is linear')
        end
        
        %------------------------------------------------------------------
        function test_1D_axisScale_doesnt_change_if_plotOverCurr(obj)
            % If have plotted 1D data on linear axes, then plot data in a 
            % second window, then issuing >> logx should result in the second
            % figure axes becoming logx (as it is the current figure), but if
            % then make the first figure current (using Matlab function: figure,
            % but not the geni_figure function make_current) and overplotting,
            % the x-axis should remain linear.
            clear_figures()
            cleanupObj = onCleanup(@clear_figures);
            
            % Plot on linear axes
            linx
            [fig1, ax1] = da(obj.w2_point(1));
            keep_figure
            % New plot
            [~, ax2] = da(obj.w2_point(2));
            logx    % change to log x-axis on the current and subsequent plots
            
            % Return focus to the first figure and 'plot over current'
            figure(fig1)
            [~, is_current] = is_genie_figure (fig1);
            assertTrue(~is_current, 'fig1 has ''current'' status, not ''keep'' status')
            assertTrue(fig1==get(groot,'CurrentFigure'), 'fig1 is not the current figure')
            
            ftmp = phoc(obj.w1_point(1));
            
            assertTrue(ftmp==fig1, 'Did not overplot on the first figure')
            assertTrue(isequal(ax1.XScale,'linear'), 'x-axis should be linear but is log')
            assertTrue(isequal(ax2.XScale,'log'), 'x-axis should be log but is linear')
        end
        
        %------------------------------------------------------------------
        function test_1D_plotOverCurrent_2D(obj)
            % Plot a 1D IX_dataset over a plot of an IX_dataset_2d (so has a
            % different genie_figure name
            clear_figures()
            cleanupObj = onCleanup(@clear_figures);
            
            [fig_h_ref, axes_h_ref, plot_h_ref] = da(obj.w2_point(1));
            [fig_h, axes_h, plot_h] = phoc(obj.w1_hist(1));
            assertTrue(fig_h==fig_h_ref, 'New figure created');
            assertTrue(axes_h==axes_h_ref, 'New axes created');
            assertTrue(numel(plot_h)==numel(plot_h_ref)+1, 'Plot missing');
        end
        
        %------------------------------------------------------------------
        function test_3D_nonUniformBins_noFigurePlotted(obj)
            % Sliceomatic requires uniform bins. No error will be thrown but
            % there should be no figure window created
            clear_figures()
            cleanupObj = onCleanup(@clear_figures);
            assertExceptionThrown(...
                @()function_caller(@sliceomatic, obj.w3_unequal), ...
                'HERBERT:IX_dataset_3d:invalid_argument');
        end
    end
end


%--------------------------------------------------------------------------
% Utility functions
%--------------------------------------------------------------------------
function clear_figures
% Delete all existing figures for a clean graphics test
fig_handles = findobj(0, 'Type', 'figure');
if ~isempty(fig_handles)
    delete(fig_handles)
end
end

%--------------------------------------------------------------------------
function function_caller(function_handle, varargin)
% Run a method or a function
% Wraps the method or function handle so that the call can be run as an argument
% in e.g. assertErrorThrown within a loop that loops over function handles
function_handle(varargin{:});
end


%--------------------------------------------------------------------------
% Create test datasets
%--------------------------------------------------------------------------
function [w1_point, w1_hist, w2_point, w2_hist, w3_point, w3_hist, ...
    w2oneD_point_xy, w2oneD_point_x_hist_y, w3_unequal] = make_data
% Make a selection of datasets for testing plot methods
%
%   w1_point    Array of two 1D datasets, point type
%               - Some overlap of the x-ranges, y-ranges have no overlap
%
%   w1_hist     Array of two 1D datasets, histogram type.
%               - The bin centres, signal and error match those of w1_point
%
%   w2_point    Array of two 2D datasets, point type on both axes
%               - The x- and y-ranges do not overlap
%
%   w2_hist     Array of two 2D datasets, histogram type on both axes.
%               - The bin centres match those of w2_point
%               - The signals are the same as the error bars in w2_point
%               - The error bars are the same as the signal in w2_point
%
%   w3_point    Array of two 3D datasets, point type on all three axes.
%               - The x-, y- and z-ranges do not overlap
%
%   w3_hist     Array of two 3D datasets, histogram type on all three axes.
%               - The bin centres match those of w3_point
%               - The signals are the same as the error bars in w3_point
%               - The error bars are the same as the signal in w3_point
%
%   w2oneD_point_xy         2D dataset, only one y value, point mode both axes
%   w2oneD_point_x_hist_y   2D dataset, only one y value, point on z, histogram y
%   w3_unequal              3D dataset with non-uniform bins along each axis


% -----------------------------
% One-dimensional datasets
% -----------------------------
% The histogram and point datasets exactly overlap if both are
% plotted using dh ('draw histogram'), or both plotted using dp
% ('draw points')
x1_1_point = 1:10;
x1_1_hist = (0:10) + 0.5;
y1_1 = 40:10:130;
e1_1 = 5 + (20:-2:2);
w1_1_point = IX_dataset_1d (x1_1_point, y1_1, e1_1, 'Title: w1_1_point', ...
    'xlabel: w1_1_point - x', 'signal: w1_1_point - signal');    % point data
w1_1_hist = IX_dataset_1d (x1_1_hist, y1_1, e1_1, 'Title: w1_1_hist', ...
    'xlabel: w1_1_hist - x', 'signal: w1_1_hist - signal');    % hist data


% A second set of point and histogram data, with an overlap in
% x-axis ranges but not in y-axis ranges compared to the above
% datsets
x1_2_point = 5:14;
x1_2_hist = (4:14) + 0.5;
y1_2 = 150:10:240;
e1_2 = 5 + (50:-5:5);
w1_2_point = IX_dataset_1d (x1_2_point, y1_2, e1_2, 'Title: w1_2_point', ...
    'xlabel: w1_2_point - x', 'signal: w1_2_point - signal');    % point data
w1_2_hist = IX_dataset_1d (x1_2_hist, y1_2, e1_2, 'Title: w1_2_hist', ...
    'xlabel: w1_2_hist - x', 'signal: w1_2_hist - signal');    % hist data


w1_point = [w1_1_point, w1_2_point];
w1_hist = [w1_1_hist, w1_2_hist];

% -----------------------------
% Two-dimensional datasets
% -----------------------------
% A dataset with just one point along the y-axis (i.e. it looks
% rather like a 1D dataset)
w2oneD_point_xy = IX_dataset_2d (11:20, 5, (101:2:120));
w2oneD_point_x_hist_y = IX_dataset_2d (11:20, [2,8], (101:2:120));

% Two datasets that have different x and y ranges so there is no
% overlap.
% - Point data along both x and y axes
% - Linear signal, 2D Gaussian error bars
x2_1 = 1:15;
y2_1 = 101:115;
[xx2_1,yy2_1] = ndgrid(x2_1,y2_1);
s2_1 = 2*xx2_1 + yy2_1;
e2_1 = exp(-((xx2_1-5).^2 + (yy2_1-110).^2)/4);
w2_1_point = IX_dataset_2d (x2_1, y2_1, s2_1, e2_1, ...
    'Title: w2_1_point', 'xlabel: w2_1_point - x', ...
    'ylabel: w2_1_point - y', 'signal: w2_1_point - signal');

x2_2 = 11:30;
y2_2 = 120:130;
[xx2_2,yy2_2] = ndgrid(x2_2,y2_2);
s2_2 = -2*xx2_2 + yy2_2;
e2_2 = 2*exp(-((xx2_2-20).^2 + (yy2_2-125).^2)/8);
w2_2_point = IX_dataset_2d (x2_2, y2_2, s2_2, e2_2, ...
    'Title: w2_2_point', 'xlabel: w2_2_point - x', ...
    'ylabel: w2_2_point - y', 'signal: w2_2_point - signal');

w2_point = [w2_1_point, w2_2_point];

% Two datasets that have different x and y ranges so there is no
% overlap.
% - Histogram data along both x and y axes
% - 2D Gaussian signal, linear error bars
x2_3 = 1:15;
x2_3_bins = (0:15) + 0.5;
y2_3 = 101:115;
y2_3_bins = (100:115) + 0.5;
[xx2_3,yy2_3] = ndgrid(x2_3,y2_3);
s2_3 = exp(-((xx2_3-5).^2 + (yy2_3-110).^2)/4);
e2_3 = 2*xx2_3 + yy2_3;
w2_1_hist = IX_dataset_2d (x2_3_bins, y2_3_bins, s2_3, e2_3, ...
    'Title: w2_1_hist', 'xlabel: w2_1_hist - x', ...
    'ylabel: w2_1_hist - y', 'signal: w2_1_hist - signal');

x2_4 = 11:30;
x2_4_bins = (10:30) + 0.5;
y2_4 = 120:130;
y2_4_bins = (119:130) + 0.5;
[xx2_4,yy2_4] = ndgrid(x2_4,y2_4);
s2_4 = 2*exp(-((xx2_4-20).^2 + (yy2_4-125).^2)/8);
e2_4 = -2*xx2_4 + yy2_4;
w2_2_hist = IX_dataset_2d (x2_4_bins, y2_4_bins, s2_4, e2_4, ...
    'Title: w2_2_hist', 'xlabel: w2_2_hist - x', ...
    'ylabel: w2_2_hist - y', 'signal: w2_2_hist - signal');

w2_hist = [w2_1_hist, w2_2_hist];


% -----------------------------
% Three-dimensional datasets
% -----------------------------
% Two small datasets that have different x,y,z ranges so there is no
% overlap.
% - Point data along x,y,z axes
% - Linear signal, 3D Gaussian error bars
x3_1 = 1:3;
y3_1 = 101:104;
z3_1 = 201:205;
[xx3_1,yy3_1,zz3_1] = ndgrid(x3_1,y3_1,z3_1);
s3_1 = 2*xx3_1 + 3*(yy3_1-100) + (zz3_1-200);
e3_1 = exp(-((xx3_1-2).^2 + (yy3_1-102).^2 + (zz3_1-203).^2)/4);
w3_1_point = IX_dataset_3d (x3_1, y3_1, z3_1, s3_1, e3_1);
w3_1_point.x_axis = 'xlabel: w3_1_point - x';
w3_1_point.y_axis = 'ylabel: w3_1_point - y';
w3_1_point.z_axis = 'zlabel: w3_1_point - z';
w3_1_point.title = {'Title: w3_1_point'};

x3_2 = 11:14;
y3_2 = 111:115;
z3_2 = 211:216;
[xx3_2,yy3_2,zz3_2] = ndgrid(x3_2,y3_2,z3_2);
s3_2 = 2*(xx3_2-10) + 3*(yy3_2-110) + (zz3_2-210);
e3_2 = exp(-((xx3_2-12).^2 + (yy3_2-113).^2 + (zz3_2-213).^2)/4);
w3_2_point = IX_dataset_3d (x3_2, y3_2, z3_2, s3_2, e3_2);
w3_2_point.x_axis = 'xlabel: w3_2_point - x';
w3_2_point.y_axis = 'ylabel: w3_2_point - y';
w3_2_point.z_axis = 'zlabel: w3_2_point - z';
w3_2_point.title = {'Title: w3_2_point'};

w3_point = [w3_1_point, w3_2_point];

% Two small datasets that have different x,y,z ranges so there is no
% overlap.
% - Histogram data along x,y,z axes
% - 3D Gaussian signal, linear error bars
x3_3 = 1:3;
y3_3 = 101:104;
z3_3 = 201:205;
[xx3_3,yy3_3,zz3_3] = ndgrid(x3_3,y3_3,z3_3);
s3_3 = exp(-((xx3_3-2).^2 + (yy3_3-102).^2 + (zz3_3-203).^2)/4);
e3_3 = 2*xx3_3 + 3*(yy3_3-100) + (zz3_3-200);
w3_1_hist = IX_dataset_3d (x3_3, y3_3, z3_3, s3_3, e3_3);
w3_1_hist.x_axis = 'xlabel: w3_1_hist - x';
w3_1_hist.y_axis = 'ylabel: w3_1_hist - y';
w3_1_hist.z_axis = 'zlabel: w3_1_hist - z';
w3_1_hist.title = {'Title: w3_1_hist'};

x3_4 = 11:14;
y3_4 = 111:115;
z3_4 = 211:216;
[xx3_4,yy3_4,zz3_4] = ndgrid(x3_4,y3_4,z3_4);
s3_4 = exp(-((xx3_4-12).^2 + (yy3_4-113).^2 + (zz3_4-213).^2)/4);
e3_4 = 2*(xx3_4-10) + 3*(yy3_4-110) + (zz3_4-210);
w3_2_hist = IX_dataset_3d (x3_4, y3_4, z3_4, s3_4, e3_4);
w3_2_hist.x_axis = 'xlabel: w3_2_hist - x';
w3_2_hist.y_axis = 'ylabel: w3_2_hist - y';
w3_2_hist.z_axis = 'zlabel: w3_2_hist - z';
w3_2_hist.title = {'Title: w3_2_hist'};

w3_hist = [w3_1_hist, w3_2_hist];


% Small 3D dataset with uneual step sizes
% THis should throw an error if try to plot it.
x3_unequal = [1,2,4];
y3_unequal = [101,103,104,107];
z3_unequal = [201,201.5,203,204,206];
[xx3_unequal,yy3_unequal,zz3_unequal] = ndgrid(x3_unequal,y3_unequal,z3_unequal);
s3_unequal = 2*xx3_unequal + 3*(yy3_unequal-100) + (zz3_unequal-200);
w3_unequal = IX_dataset_3d (x3_unequal, y3_unequal, z3_unequal, s3_unequal);
w3_unequal.x_axis = 'x-axis caption';
w3_unequal.y_axis = 'y-axis caption';
w3_unequal.z_axis = 'z-axis caption';
w3_unequal.title = {'The Title'};

end
