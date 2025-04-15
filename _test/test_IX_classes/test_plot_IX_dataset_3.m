classdef test_plot_IX_dataset_3 < TestCase
    % Test plotting of IX_dataset_1d, IX_dataset_2d and IX_dataset_3d objects
    %
    % The tests are for 
    % - the validity of 
    properties
        data1D
        data2D
        data3D

        colorNames
        colorCodes
        line_style_names
        line_style_codes
        marker_type_names
        marker_type_codes
    end

    methods
        function obj = test_plot_IX_dataset_3(varargin)
            obj = obj@TestCase('test_plot_IX_dataset');
            
            % Load example 1D, 2D, 3D, IX_dataset_*d objects
            hp = horace_paths().test_common;    % common data location

            sqw_1d_file = fullfile(hp, 'sqw_1d_1.sqw');
            sqw_2d_file = fullfile(hp, 'sqw_2d_1.sqw');
            sqw_3d_file = fullfile(hp, 'w3d_sqw.sqw');
            
            obj.data1D = IX_dataset_1d(read_dnd(sqw_1d_file));
            obj.data2D = IX_dataset_2d(read_dnd(sqw_2d_file));
            obj.data3D = IX_dataset_3d(read_dnd(sqw_3d_file));           
            
            % Valid colours, line styles and marker types:
            % - colorCodes are how the colours are stored in genieplot
            obj.colorNames = {...
                'red', 'green', 'blue', 'cyan', 'magenta', 'yellow', 'black', 'white', ...
                'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w', ...
                'denim', 'carrot', 'marigold', 'purple', 'grass', 'babyblue', 'brickred'};
            obj.colorCodes = {'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w', ...
                'r', 'g', 'b', 'c', 'm', 'y', 'k', 'w', ...
                '#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
            
            % - line_style_codes are how line styles are stored in genieplot
            obj.line_style_names = {'solid','dashed','dotted','ddot'};
            obj.line_style_codes = {'-',  '--',  ':',  '-.'};
            
            % marker_type_codes are how marker type are stored in genieplot
            if verLessThan('MATLAB','9.9')  % prior to R2020b
                obj.marker_type_names = {'o','+','*','.','x','square','diamond', ...
                    '^','v','>','<','pentagram','hexagram'};
                obj.marker_type_codes = ...
                    {'o','+','*','.','x','s','d','^','v','>','<','p','h'};
            else
                obj.marker_type_names = {'o','+','*','.','x','_','|','square','diamond', ...
                    '^','v','>','<','pentagram','hexagram'};
                obj.marker_type_codes = ...
                    {'o','+','*','.','x','_','|','s','d','^','v','>','<','p','h'};
            end
        end
        
        %------------------------------------------------------------------
        % Test aline
        %------------------------------------------------------------------
        function test_aline_loopSetScalarStyleName(obj)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            for i = 1:numel(obj.line_style_names)
                line_style_name = obj.line_style_names{i};
                line_style_code = obj.line_style_codes{i};
                aline(line_style_name)
                genie_line_properties_test({line_style_code}, [], i);
            end
        end
        
        function test_aline_loopSetScalarStyleCode(obj)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            for i = 1:numel(obj.line_style_codes)
                line_style_code = obj.line_style_codes{i};
                aline(line_style_code)
                genie_line_properties_test({line_style_code}, [], i);
            end
        end
        
        function test_aline_setScalarWidth(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline (2.718)
            genie_line_properties_test([], 2.718);
        end
        
        function test_aline_setScalarStyleName(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline ('dot')
            genie_line_properties_test({':'}, []);
        end

        function test_aline_setScalarStyleCode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline ('-.')
            genie_line_properties_test({'-.'}, []);
        end

        function test_aline_setScalarWidthAndStyleName(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline (0.5, 'dot')
            genie_line_properties_test({':'}, 0.5);
        end

        function test_aline_setScalarStyleNameAndWidth(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline ('dot', 0.5)
            genie_line_properties_test({':'}, 0.5);
        end

        function test_aline_setScalarStyleCodeAndWidth(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline  (':', 0.5)
            genie_line_properties_test({':'}, 0.5);
        end
        
        function test_aline_setScalarWidth_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline 2.718
            genie_line_properties_test([], 2.718);
        end
        
        function test_aline_setScalarStyleCode_ddot_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline -.
            genie_line_properties_test({'-.'}, []);
        end

        function test_aline_setScalarStyleCode_dot_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline :
            genie_line_properties_test({':'}, []);
        end

        function test_aline_setScalarWidthAndStyleName_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            dot = {[14,15],'nog'};  % try to confuse command syntax parser in aline
            aline 0.5 dot
            genie_line_properties_test({':'}, 0.5);
        end

        function test_aline_setScalarStyleNameAndWidth_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline dot 0.5
            genie_line_properties_test({':'}, 0.5);
        end

        function test_aline_setScalarStyleCodeAndWidth_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            % The cases of using a colon or minus sign as an argument with
            % command syntax is ambiguous if there are further
            % characters, as e.g. >> aline : 0.5 is seem as a syntax warning
            % and >> aline - 0.5 is a valid arithmetic statement.
            % Until we can find a way of changing Matlab behaviour in a robut
            % way, catch this test.
            % The following will be interpreted as >> aline
            aline  :  0.5
            styles = genieplot.get('line_styles');
            widths = genieplot.get('line_widths');
            assertFalse(isequal(styles, ':'), 'Mysteriously now working ???')
            assertFalse(isequal(widths, '0.5'), 'Mysteriously now working ???')
            
            % This will work:
            aline ':' 0.5
            genie_line_properties_test({':'}, 0.5);
        end

        function test_aline_setVectorWidthAndStylecode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline (1, 2, '--', '-', '-.')
            genie_line_properties_test({'--', '-', '-.'}, [1,2]);
        end

        function test_aline_setVectorStylecodeAndWidthAndStylecode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline (':', 1, 2, '--', '-', '-.')
            genie_line_properties_test({':', '--', '-', '-.'}, [1,2]);
        end

        function test_aline_setVectorStylenameAndWidth(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline ({'dot','sol'}, 1:2:7)
            genie_line_properties_test({':', '-'}, [1,3,5,7]);
        end

        function test_aline_setVectorStylenameCapsAndWidth(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline ({'DOT','SOL'}, 1:2:7)
            genie_line_properties_test({':', '-'}, [1,3,5,7]);
        end

        function test_aline_setVectorStylecodeOrNameAndWidth(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline ({':','sol'}, 1:2:7)
            genie_line_properties_test({':', '-'}, [1,3,5,7]);
        end

        function test_aline_setVectorStylecodeAndWidth(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline ({':','-'}, 1:2:7)
            genie_line_properties_test({':', '-'}, [1,3,5,7]);
        end

        function test_aline_setVectorWidthAndStylecode_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline  1  2  --  -  -.
            genie_line_properties_test({'--', '-', '-.'}, [1,2]);
        end

        function test_aline_setVectorStylenameAndWidth_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline  dot  sol  1:2:7
            genie_line_properties_test({':', '-'}, [1,3,5,7]);
        end

        function test_aline_setVectorStylenameCapsAndWidth_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            aline  DOT  SOL  1:2:7
            genie_line_properties_test({':', '-'}, [1,3,5,7]);
        end

        function test_aline_scalarStyle_output(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            [width_out, style_out] = aline('dot', '4.5');
            assertEqual(width_out, 4.5)
            assertEqual(style_out, ':')
        end
        
        function test_aline_vectorStyle_output(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            [width_out, style_out] = aline('dot', [5,6,8], 'sol');
            assertEqual(width_out, [5,6,8])
            assertEqual(style_out, {':', '-'})
        end
        
        
        %------------------------------------------------------------------
        % Test amark
        %------------------------------------------------------------------
        function test_amark_loopSetScalarMarkerCode(obj)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            for i = 1:numel(obj.marker_type_names)
                marker_type_code = obj.marker_type_codes{i};
                amark(marker_type_code)
                genie_marker_properties_test({marker_type_code}, [], i);
            end
        end
                
        function test_amark_loopSetScalarMarkerName(obj)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            for i = 1:numel(obj.marker_type_names)
                marker_type_name = obj.marker_type_names{i};
                marker_type_code = obj.marker_type_codes{i};
                amark(marker_type_name)
                genie_marker_properties_test({marker_type_code}, [], i);
            end
        end
        
        function test_amark_setScalarSize(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark (9.5)
            genie_marker_properties_test([], 9.5);
        end
        
        function test_amark_setScalarMarkerName(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark ('diam')
            genie_marker_properties_test({'d'}, []);
        end

        function test_amark_setScalarMarkerCode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark ('D')
            genie_marker_properties_test({'d'}, []);    % checks case insensitivity too
        end

        function test_amark_setScalarSizeAndMarkerName(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark (4.5, 'diam')
            genie_marker_properties_test({'d'}, 4.5);
        end

        function test_amark_setScalarMarkerNameAndSize(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark ('diam', 4.5)
            genie_marker_properties_test({'d'}, 4.5);
        end

        function test_amark_setScalarMarkerCodeAndSize(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark  ('+', 4.5)
            genie_marker_properties_test({'+'}, 4.5);
        end
        
        function test_amark_setScalarSize_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark 9.5
            genie_marker_properties_test([], 9.5);
        end
        
        function test_amark_setScalarMarkerCode_plus_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark +
            genie_marker_properties_test({'+'}, []);
        end

        function test_amark_setScalarSizeAndMarkerName_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            diam = {[14,15],'nog'};  % try to confuse command syntax parser in amark
            amark 4.5 diam
            genie_marker_properties_test({'d'}, 4.5);
        end

        function test_amark_setScalarMarkerNameAndSize_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark diam 4.5
            genie_marker_properties_test({'d'}, 4.5);
        end

        function test_amark_setScalarMarkerCodeAndSize_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            % The cases of using '+'   '*'   '^'   '>'   '<'   '|'  with
            % command syntax is ambiguous if there are further
            % characters, as e.g. >> amark + 4.5 is a valid arithmetic statement.
            % Until we can find a way of changing Matlab behaviour in a robut
            % way, catch this test.
            % The following will be interpreted as >> aline
            amark  +  4.5
            types = genieplot.get('marker_types');
            sizes = genieplot.get('marker_sizes');
            assertFalse(isequal(types, ':'), 'Mysteriously now working ???')
            assertFalse(isequal(sizes, '4.5'), 'Mysteriously now working ???')

            % This will work:
            amark '+' 4.5
            genie_marker_properties_test({'+'}, 4.5);
        end

        function test_amark_setVectorSizeAndMarkerCode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark (5, 10, 'x', 'o', 'p')
            genie_marker_properties_test({'x', 'o', 'p'}, [5,10]);
        end

        function test_amark_setVectorMarkerCodeAndSizeAndMarkerCode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark ('+', 5, 10, '*', 'diam', '>')
            genie_marker_properties_test({'+', '*', 'd', '>'}, [5,10]);
        end

        function test_amark_setVectorMarkerNameAndSize(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark ({'v','p'}, 1:2:7)
            genie_marker_properties_test({'v', 'p'}, [1,3,5,7]);
        end

        function test_amark_setVectorMarkerNameCapsAndSize(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark ({'V','P'}, 1:2:7)
            genie_marker_properties_test({'v', 'p'}, [1,3,5,7]);
        end

        function test_amark_setVectorSizeAndMarkerCode_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark  5  10  x  o  p
            genie_marker_properties_test({'x', 'o', 'p'}, [5,10]);
        end

        function test_amark_setVectorMarkerNameAndSize_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark  v  p  1:2:7
            genie_marker_properties_test({'v', 'p'}, [1,3,5,7]);
        end

        function test_amark_setVectorMarkerNameCapsAndSize_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            amark  V  P  1:2:7
            genie_marker_properties_test({'v', 'p'}, [1,3,5,7]);
        end

        function test_amark_scalarMarkerName_output(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            [size_out, markerCode_out] = amark('pent', 4.5);
            assertEqual(size_out, 4.5)
            assertEqual(markerCode_out, 'p')
        end
        
        function test_amark_vectorMarkerName_output(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            [size_out, markerCode_out] = amark('pent', [5,6,8], 'diam');
            assertEqual(size_out, [5,6,8])
            assertEqual(markerCode_out, {'p', 'd'})
        end
        
        
        %------------------------------------------------------------------
        % Test acolor
        %------------------------------------------------------------------
        function test_acolor_setScalarCycle_fast(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('-fast')
            genie_colors_test([], 'fast');
        end
        
        function test_acolor_setScalarCycle_with(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('-wi')
            genie_colors_test([], 'with');
        end
        
        function test_acolor_setScalarCycle_ERROR(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            f = @()acolor('wi');
            assertExceptionThrown(f, 'HERBERT:graphics:invalid_argument');
        end
        
        function test_acolor_loopSetScalarColorName(obj)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            for i = 1:numel(obj.colorNames)
                color_name = obj.colorNames{i};
                color_code = obj.colorCodes{i};
                acolor(color_name)
                genie_colors_test({color_code}, [], i);
            end
        end
        
        function test_acolor_loopSetScalarColorCode(obj)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            for i = 1:numel(obj.colorCodes)
                color_code = obj.colorCodes{i};
                acolor(color_code)
                genie_colors_test({color_code}, [], i);
            end
        end
        
        function test_acolor_setScalarColorCode_functionMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('re')
            genie_colors_test({'r'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor re
            genie_colors_test({'r'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode_evalTest(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            re = 15;        % try to confuse command syntax parser in acolor
            acolor re
            genie_colors_test({'r'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode_blackAbbrev(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('bla')
            genie_colors_test({'k'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode_blackAbbrevr(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor bla
            genie_colors_test({'k'}, []);
        end
        
        function test_acolor_setVectorColorCode_functionMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('r', 'b', 'bla', 'g')
            genie_colors_test({'r', 'b', 'k', 'g'}, []);
        end
        
        function test_acolor_setVectorColorCode_and_cycle_functionMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('r', 'b', 'bla', 'g', '-wi')
            genie_colors_test({'r', 'b', 'k', 'g'}, []);
        end
        
        function test_acolor_setVectorColorCode_and_cycle_functionMode_ERROR(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            f = @()acolor('r', 'b', 'bla', '-wi', 'g'); % error: cycle set in middle of colours
            assertExceptionThrown(f, 'HERBERT:graphics:invalid_argument');
        end
        
        function test_acolor_setVectorColorCode_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor r  b  bla  g
            genie_colors_test({'r', 'b', 'k', 'g'}, []);
        end
        
        function test_acolor_setVectorColorCode_and_cycle_commandMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor r  b  bla  g -with
            genie_colors_test({'r', 'b', 'k', 'g'}, 'with');
        end
        
        function test_acolor_setVectorColorCode_and_cycle_commandMode_ERROR(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            try
                acolor r  b  bla -with  g  % error: cycle set in middle of colours
                failed = false;
            catch
                failed = true;
            end
            assertTrue(failed, 'Should have thrown error but did not.')
        end
        
        function test_acolor_setCellVectorColorCode_functionMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor({'r', 'y', 'bla'})
            genie_colors_test({'r', 'y', 'k'}, []);
        end
        
        function test_acolor_setCellVectorColorCode_and_cycle_functionMode(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor({'r', 'y', 'bla'}, '-wi')
            genie_colors_test({'r', 'y', 'k'}, 'with');
        end
        
        function test_acolor_singleColor_output(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            [col_out, cycle_out] = acolor('g', '-fa');
            assertEqual(col_out, 'green')
            assertEqual(cycle_out, 'fast')
        end
        
        function test_acolor_vectorColor_output(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            [col_out, cycle_out] = acolor('r', 'y', 'bla', '-wi');
            assertEqual(col_out, {'red', 'yellow', 'black'})
            assertEqual(cycle_out, 'with')
        end
        
        function test_acolor_vectorColorAndPalette_output(~)
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            [col_out, cycle_out] = acolor('r', 'gem', 'bla', '-wi');
            assertEqual(col_out, {'red', 'denim', 'carrot', 'marigold', ...
                'purple', 'grass', 'babyblue', 'brickred', 'black'})
            assertEqual(cycle_out, 'with')
        end
        
        %------------------------------------------------------------------
        % Test cascade of 
        %------------------------------------------------------------------
        function test_cyclePlotProperties_colorsFast(obj)
            % Cycle colors 'fast', so that all colors are cycled through before
            % incrementing the line and mark styles/types and widths/sizes 
            
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('-fast')
            acolor ('r', 'b', 'y')
            aline('-', '--', 0.5, 1, 2)
            amark('o','*','x','s', 3, 6)
            col_ref = {[1,0,0], [0,0,1], [1,1,0], [1,0,0], [0,0,1], [1,1,0], ...
                [1,0,0], [0,0,1], [1,1,0], [1,0,0], [0,0,1], [1,1,0]};
            lineStyle_ref = {'-', '-', '-', '--', '--', '--', '-', '-', '-', '--', '--', '--'};
            lineWidth_ref = [0.5, 0.5, 0.5, 1, 1, 1, 2, 2, 2, 0.5, 0.5, 0.5];
            markerType_ref = {'o','o','o','*','*','*','x','x','x','square','square','square'};
            markerSize_ref = [3, 3, 3, 6, 6, 6, 3, 3, 3, 6, 6, 6];

            nplot = 12;
            data1D_arr = arrayfun(@mtimes, repmat(obj.data1D,1,12), 1:12);
            [~, ~, plot_h] = dd(data1D_arr);
            for i=1:12
                j = nplot + 1 - i;  % plot handles in reverse order (1 was last plot etc.)
                assertEqual(plot_h(j).Color, col_ref{i}, ...
                    ['Color error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).LineStyle, lineStyle_ref{i}, ...
                    ['lineStyle error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).LineWidth, lineWidth_ref(i), ...
                    ['lineWidth error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).Marker, markerType_ref{i}, ...
                    ['Marker error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).MarkerSize, markerSize_ref(i), ...
                    ['MarkerSize error, plot handle ', num2str(j)])
            end
        end
        
        function test_cyclePlotProperties_colorsWith(obj)
            % Cycle colors 'fast', so that all colors are cycled through before
            % incrementing the line and mark styles/types and widths/sizes 
            
            genieplot_initialise('fast')    % initialise to some unlikely values
            % Test proper:
            acolor('-with')
            acolor ('r', 'b', 'y')
            aline('-', '--', 0.5, 1, 2)
            amark('o','*','x','s', 3, 6)
            col_ref = {[1,0,0], [0,0,1], [1,1,0], [1,0,0], [0,0,1], [1,1,0], ...
                [1,0,0], [0,0,1], [1,1,0], [1,0,0], [0,0,1], [1,1,0]};
            lineStyle_ref = {'-', '--', '-', '--', '-', '--', '-', '--', '-', '--', '-', '--'};
            lineWidth_ref = [0.5, 1, 2, 0.5, 1, 2, 0.5, 1, 2, 0.5, 1, 2];
            markerType_ref = {'o','*','x','square','o','*','x','square','o','*','x','square'};
            markerSize_ref = [3, 6, 3, 6, 3, 6, 3, 6, 3, 6, 3, 6];

            nplot = 12;
            data1D_arr = arrayfun(@mtimes, repmat(obj.data1D,1,12), 1:12);
            [~, ~, plot_h] = dd(data1D_arr);
            for i=1:12
                j = nplot + 1 - i;  % plot handles in reverse order (1 was last plot etc.)
                assertEqual(plot_h(j).Color, col_ref{i}, ...
                    ['Color error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).LineStyle, lineStyle_ref{i}, ...
                    ['lineStyle error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).LineWidth, lineWidth_ref(i), ...
                    ['lineWidth error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).Marker, markerType_ref{i}, ...
                    ['Marker error, plot handle ', num2str(j)])
                assertEqual(plot_h(j).MarkerSize, markerSize_ref(i), ...
                    ['MarkerSize error, plot handle ', num2str(j)])
            end
        end
        %------------------------------------------------------------------
    end
end


%--------------------------------------------------------------------------
function genieplot_initialise(color_cycle)
% Set genieplot parameters so that we always start the tests with the same setup
% for line, mark and color.
% Set to something we'll never likely set in the tests.
% However, color_cycle can only take one of two values, so this is taken as an
% input argument.
genieplot.set('color_cycle',color_cycle)
genieplot.set('colors',{'#0071BA','#D75319','#EDB113'})
genieplot.set('line_styles', {'-.',':','-.',':','-.',':','-.',':'})
genieplot.set('line_widths', [1.3,6,34,36,5.3368,3.7,5.4,7.5,5,15,14,6,66,56,5])
genieplot.set('marker_types',{'x','<','*','x','<','+','x','<','*','x','^','*'})
genieplot.set('marker_sizes',[1.3,6.34327,3.35784,36,5.3368,3.1856377,5.4,7])
end

%--------------------------------------------------------------------------
function genie_line_properties_test(styles_ref, widths_ref, suffix)
% Utility to perform tests of genie line widths and styles. Isolates code that
% is repeated countless times in tests.
%
%   >> genie_line_properties_test(styles_ref, widths_ref)
%   >> genie_line_properties_test(styles_ref, widths_ref, index)
% 
% Optional suffix is added to error message should the test fail. 
% If the suffix is numeric, then it is assumed to be a loop index. Useful when
% debugging a test that loops over values. 
%
% Set the test value to [] to skip the test.
%
% Anything else is assumed to be the reference value against wich to check for
% equality.
%
% EXAMPLES:
%   >> genie_line_properties_test({'-'}, [2,4])
%   >> genie_line_properties_test({'-',--'}, [2,4,7], 'Oh no!')
%   >> genie_line_properties_test([], [2,4], 5)

styles = genieplot.get('line_styles');
widths = genieplot.get('line_widths');
if nargin>2
    if is_string(suffix)
        index_string = suffix;
    else
        index_string = [' (index = ', num2str(suffix), ')'];
    end
else
    index_string = '';
end

if ~isempty(styles_ref)
    assertEqual(styles, styles_ref, ...
        ['''line_styles'' does not match expectations', index_string])
end
if ~isempty(widths_ref)
    assertEqual(widths, widths_ref, ...
        ['''line_widths'' does not match expectations', index_string])
end
end

%--------------------------------------------------------------------------
function genie_marker_properties_test(types_ref, sizes_ref, suffix)
% Utility to perform tests of genie marker types and sizes. Isolates code that
% is repeated countless times in tests.
%
%   >> genie_marker_properties_test(types_ref, sizes_ref)
%   >> genie_marker_properties_test(types_ref, sizes_ref, index)
% 
% Optional suffix is added to error message should the test fail. 
% If the suffix is numeric, then it is assumed to be a loop index. Useful when
% debugging a test that loops over values. 
%
% Set the test value to [] to skip the test.
%
% Anything else is assumed to be the reference value against wich to check for
% equality.
%
% EXAMPLES:
%   >> genie_marker_properties_test({'*'}, [2,4])
%   >> genie_marker_properties_test({'*','o'}, [2,4,7], 'Oh no!')
%   >> genie_marker_properties_test([], [2,4], 5)

types = genieplot.get('marker_types');
sizes = genieplot.get('marker_sizes');
if nargin>2
    if is_string(suffix)
        index_string = suffix;
    else
        index_string = [' (index = ', num2str(suffix), ')'];
    end
else
    index_string = '';
end

if ~isempty(types_ref)
    assertEqual(types, types_ref, ...
        ['''marker_types'' does not match expectations', index_string])
end
if ~isempty(sizes_ref)
    assertEqual(sizes, sizes_ref, ...
        ['''marker_sizes'' does not match expectations', index_string])
end
end

%--------------------------------------------------------------------------
function genie_colors_test(colors_ref, cycle_ref, suffix)
% Utility to perform tests of genie marker types and sizes. Isolates code that
% is repeated countless times in tests.
%
%   >> genie_colors_test(color_ref, cycle_ref)
%   >> genie_colors_test(color_ref, cycle_ref, index)
% 
% Optional suffix is added to error message should the test fail. 
% If the suffix is numeric, then it is assumed to be a loop index. Useful when
% debugging a test that loops over values. 
%
% Set the test value to [] to skip the test.
%
% Anything else is assumed to be the reference value against wich to check for
% equality.
%
% EXAMPLES:
%   >> genie_colors_test({'red'}, 'fast')
%   >> genie_colors_test({'red', 'green', '#0072BD'}, 'fast', 'Oh no!')
%   >> genie_colors_test([], 'with', 5)

colors = genieplot.get('colors');
cycle = genieplot.get('color_cycle');
if nargin>2
    if is_string(suffix)
        index_string = suffix;
    else
        index_string = [' (index = ', num2str(suffix), ')'];
    end
else
    index_string = '';
end

if ~isempty(colors_ref)
    assertEqual(colors, colors_ref, ...
        ['''colors'' does not match expectations', index_string])
end
if ~isempty(cycle_ref)
    assertEqual(cycle, cycle_ref, ...
        ['''color_cycle'' does not match expectations', index_string])
end
end
