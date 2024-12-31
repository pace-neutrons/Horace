classdef test_plot_limits < TestCase
    % Test the function lx, ly, lz, lc for constrolling the axis limits of plots
    
    properties
        genie_figure_private_folder
        w1_1_point
        w1_2_point
        w1_1_hist
        w1_2_hist
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_plot_limits (name)
            obj = obj@TestCase(name);
            
            % Get location of genie_figure private functions (this is so that in
            % the tests we can cd to that folder and test the functions directly)
            genie_figure_folder = fileparts(which('genie_figure_create'));
            obj.genie_figure_private_folder = fullfile(genie_figure_folder,'private');
            
            % One-dimensional datasets
            % ------------------------
            % The histogram and point datasets exactly overlap if both are
            % plotted using dh ('draw histogram'), or both plotted using dp
            % ('draw points')
            x1_1_point = 1:10;
            x1_1_hist = (0:10) + 0.5;
            y1_1 = 10:10:100;
            e1_1 = 5 + (20:-2:2);
            w1_1_point = IX_dataset_1d (x1_1_point, y1_1, e1_1);    % point data
            w1_1_hist = IX_dataset_1d (x1_1_hist, y1_1, e1_1);      % histogram data
            
            % A second set of point and histogram data, with an overlap in
            % x-axis ranges but not in y-axis ranges compared to the above
            % datsets
            x1_2_point = 5:14;
            x1_2_hist = (4:14) + 0.5;
            y1_2 = 150:10:240;
            e1_2 = 5 + (50:-5:5);
            w1_2_point = IX_dataset_1d (x1_2_point, y1_2, e1_2);
            w1_2_hist = IX_dataset_1d (x1_2_hist, y1_2, e1_2);
            
            % Two-dimensional datasets
            % ------------------------
            % A dataset with just one point along the y-axis (i.e. it looks
            % rather like a 1D dataset)
            w2_point_xy = IX_dataset_2d (11:20, 5, (101:2:120));
            w2_point_x_hist_y = IX_dataset_2d (11:20, [2,8], (101:2:120));
            
            x2_1 = 1:15;
            y2_1 = 101:115;
            [xx2_1,yy2_1] = ndgrid(x2_1,y2_1);
            s2_1 = 2*xx2_1 + yy2_1;
            w2_1_point_xy = IX_dataset_2d (x2_1, y2_1, s2_1);
            
            x2_2 = 11:30;
            y2_2 = 120:130;
            [xx2_2,yy2_2] = ndgrid(x2_2,y2_2);
            s2_2 = -2*xx2_2 + yy2_2;
            w2_2_point_xy = IX_dataset_2d (x2_2, y2_2, s2_2);
            
            x2_3 = 1:15;
            y2_3 = 101:115;
            [xx2_3,yy2_3] = ndgrid(x2_3,y2_3);
            s2_3 = exp(-((xx2_3-5).^2 + (yy2_3-110).^2)/4);
            w2_3_point_xy = IX_dataset_2d (x2_3, y2_3, s2_3);
            
            x2_4 = 11:30;
            y2_4 = 120:130;
            [xx2_4,yy2_4] = ndgrid(x2_4,y2_4);
            s2_4 = 2*exp(-((xx2_4-20).^2 + (yy2_4-125).^2)/8);
            w2_4_point_xy = IX_dataset_2d (x2_4, y2_4, s2_4);
            
            
            % Package as class properties
            % ---------------------------
            obj.w1_1_point = w1_1_point;
            obj.w1_2_point = w1_2_point;
            obj.w1_1_hist = w1_1_hist;
            obj.w1_2_hist = w1_2_hist;
            
        end
        
        %--------------------------------------------------------------------------
        function test_default_plot_limits_1D(obj)
            % Check plot limits are the joint full range of x and y data
            
            % Plot a pair of 1D line plots
            dl(obj.w1_1_point)
            pl(obj.w1_2_point)
            
            % Test plot limits
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            assertEqual(xlim,[1,14])
            assertEqual(ylim,[10,240])
        end
        
        %--------------------------------------------------------------------------
        function test_lx_1D_reduced_ylims(obj)
            % Check y-range is altered if reduce x-axis range
            
            % Plot a pair of 1D line plots
            dl(obj.w1_1_point)
            pl(obj.w1_2_point)

            % Reduce x-axis range; y range should be reduced
            lx 3 8
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            assertEqual(xlim,[3,8])
            assertEqual(ylim,[30,180])
        end
        
        %--------------------------------------------------------------------------
        function test_lx_1D_expanded_ylims(obj)
            % Check y-range is altered if increase x-axis range
            
            % Plot a pair of 1D line plots
            dl(obj.w1_1_point)
            pl(obj.w1_2_point)

            % Reduce x-axis range (tested above to correctly reduce y range)
            lx 3 8
            
            % Increase x range; y range should be increased
            lx 2 12
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            assertEqual(xlim,[2,12])
            assertEqual(ylim,[20,220])
        end
        
        %--------------------------------------------------------------------------
        function test_lx_1D_default_xylims(obj)
            % Check ranges if x-axis range is altered to default
            
            % Plot a pair of 1D line plots
            dl(obj.w1_1_point)
            pl(obj.w1_2_point)

            % Reduce x-axis range (tested above to correctly reduce y range)
            lx 3 8
            
            % Increase x range to default; y range should also increase default
            lx
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            assertEqual(xlim,[1,14])
            assertEqual(ylim,[10,240])
        end
        
        %--------------------------------------------------------------------------
        function test_ly_1D_reduced_xlims(obj)
            % Check x-range is altered if reduce y-axis range
            
            % Plot a pair of 1D line plots
            dl(obj.w1_1_point)
            pl(obj.w1_2_point)

            % Reduce y-axis range; x range should be reduced
            ly 40 210
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            assertEqual(xlim,[4,11])
            assertEqual(ylim,[40,210])
        end
        
        %--------------------------------------------------------------------------
        function test_ly_1D_expanded_xlims(obj)
            % Check x-range is altered if increase y-axis range
            
            % Plot a pair of 1D line plots
            dl(obj.w1_1_point)
            pl(obj.w1_2_point)

            % Reduce y-axis range (tested above to correctly reduce x range)
            ly 40 210
            
            % Increase y range; x range should be increased
            ly 20 220
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            assertEqual(xlim,[2,12])
            assertEqual(ylim,[20,220])
        end
        
        %--------------------------------------------------------------------------
        function test_ly_1D_default_xylims(obj)
            % Check ranges if y-axis range is altered to default
            
            % Plot a pair of 1D line plots
            dl(obj.w1_1_point)
            pl(obj.w1_2_point)

            % Reduce y-axis range (tested above to correctly reduce x range)
            ly 40 210
            
            % Increase y range to default; x range should also increase default
            ly
            xlim=get(gca,'XLim');
            ylim=get(gca,'YLim');
            assertEqual(xlim,[1,14])
            assertEqual(ylim,[10,240])
        end
        
        
        
        
        
        
        
        
        %--------------------------------------------------------------------------
        function test_graph_data_present_1D(obj)
            % Test only x and y data present for 1D line plot
            curr_dir = pwd();
            cleanupObj = onCleanup(@()cleanupFun(curr_dir));    % return to pwd on exit
            
            cd(obj.genie_figure_private_folder)     % go to graphics private folder
            dp(obj.w1point_1)                       % make a 1D plot
            present = graph_data_present(gcf);
            [ok, mess] = validate_present(present, [1,1,0,0]);
            assertTrue(ok, mess)
        end
        
        %--------------------------------------------------------------------------
        function test_graph_data_present_2D(obj)
            % Test only x and y data present for 1D line plot
            curr_dir = pwd();
            cleanupObj = onCleanup(@()cleanupFun(curr_dir));    % return to pwd on exit
            
            cd(obj.genie_figure_private_folder)     % go to graphics private folder
            dp(obj.w1point_1)                       % make a 1D plot
            present = graph_data_present(gcf);
            [ok, mess] = validate_present(present, [1,1,0,0]);
            assertTrue(ok, mess)
        end
        
        %--------------------------------------------------------------------------
    end
    
end

%-------------------------------------------------------------------------------
function cleanupFun (dir)
% Return to named folder
cd(dir)
end

%-------------------------------------------------------------------------------
function [ok, mess] = validate_present(present, test_vals)
% Check that the output argument of graph_data_present matches the test vector,
% which must be a logical vector length 4 or a numeric vector length 4 of a mix
% of zeros or ones.

ok = true;
mess = '';

if numel(test_vals)==4 && islognum(test_vals)
    test = logical(test_vals);     % convert type if need to
    if present.x~=test(1) ||  present.y~=test(2) ||  present.z~=test(3) ||...
            present.c~=test(4)
        ok = false;
        mess = 'Returned structure does not match expected value';
    end
else
    ok = false;
    mess = 'test values have wrong size and/or type';
end

end

