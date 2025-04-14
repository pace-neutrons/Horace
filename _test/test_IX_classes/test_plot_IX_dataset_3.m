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
        function test_aline_setScalarWidth(~)
            aline(2.718)
            genie_line_properties_test([], 2.718);
        end
        
        function test_aline_setScalarStyleName(obj)
            for i = 1:numel(obj.line_style_names)
                line_style_name = obj.line_style_names{i};
                line_style_code = obj.line_style_codes{i};
                aline(line_style_name)
                genie_line_properties_test({line_style_code}, [], i);
            end
        end
        
        function test_aline_setScalarStyleCode(obj)
            for i = 1:numel(obj.line_style_codes)
                line_style_code = obj.line_style_codes{i};
                aline(line_style_code)
                genie_line_properties_test({line_style_code}, [], i);
            end
        end
        
        %------------------------------------------------------------------
        % Test amark
        %------------------------------------------------------------------
        function test_amark_setScalarSize(~)
            amark(8.5)
            genie_marker_properties_test([], 8.5);
        end
        
        function test_amark_setScalarMarkerName(obj)
            for i = 1:numel(obj.marker_type_names)
                marker_type_name = obj.marker_type_names{i};
                marker_type_code = obj.marker_type_codes{i};
                amark(marker_type_name)
                genie_marker_properties_test({marker_type_code}, [], i);
            end
        end
        
        function test_amark_setScalarMarkerCode(obj)
            for i = 1:numel(obj.marker_type_codes)
                marker_type_code = obj.marker_type_codes{i};
                amark(marker_type_code)
                genie_marker_properties_test({marker_type_code}, [], i);
            end
        end
        
        %------------------------------------------------------------------
        % Test acolor
        %------------------------------------------------------------------
        function test_acolor_setScalarCycle_fast(~)
            acolor('-fast')
            genie_colors_test([], 'fast');
        end
        
        function test_acolor_setScalarCycle_with(~)
            acolor('-wi')
            genie_colors_test([], 'with');
        end
        
        function test_acolor_setScalarCycle_ERROR(~)
            f = @()acolor('wi');
            assertExceptionThrown(f, 'HERBERT:graphics:invalid_argument');
        end
        
        function test_acolor_setScalarColorName(obj)
            for i = 1:numel(obj.colorNames)
                color_name = obj.colorNames{i};
                color_code = obj.colorCodes{i};
                acolor(color_name)
                genie_colors_test({color_code}, [], i);
            end
        end
        
        function test_acolor_setScalarColorCode(obj)
            for i = 1:numel(obj.colorCodes)
                color_code = obj.colorCodes{i};
                acolor(color_code)
                genie_colors_test({color_code}, [], i);
            end
        end
        
        function test_acolor_setScalarColorCode_functionMode(~)
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            acolor('re')
            genie_colors_test({'r'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode(~)
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            acolor re
            genie_colors_test({'r'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode_evalTest(~)
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            re = 15;        % try to confuse command syntax parser in acolor
            acolor re
            genie_colors_test({'r'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode_blackAbbrev(~)
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            acolor('bla')
            genie_colors_test({'k'}, []);
        end
        
        function test_acolor_setScalarColorCode_commandMode_blackAbbrevr(~)
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            acolor bla
            genie_colors_test({'k'}, []);
        end
        
        function test_acolor_setVectorColorCode_functionMode(~)
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            acolor('r', 'b', 'bla', 'g')
            genie_colors_test({'r', 'b', 'k', 'g'}, []);
        end
        
        function test_acolor_setVectorColorCode_and_cycle_functionMode(~)
            acolor('g')     % set to something other than what we are testing
            acolor('-fast')
            genie_colors_test({'g'}, 'fast');   % check it is set
            % Test proper:
            acolor('r', 'b', 'bla', 'g', '-wi')
            genie_colors_test({'r', 'b', 'k', 'g'}, []);
        end
        
        function test_acolor_setVectorColorCode_and_cycle_functionMode_ERROR(~)
            acolor('g')     % set to something other than what we are testing
            acolor('-fast')
            genie_colors_test({'g'}, 'fast');   % check it is set
            % Test proper:
            f = @()acolor('r', 'b', 'bla', '-wi', 'g'); % error: cycle set in middle of colours
            assertExceptionThrown(f, 'HERBERT:graphics:invalid_argument');
        end
        
        function test_acolor_setVectorColorCode_commandMode(~)
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            acolor r  b  bla  g
            genie_colors_test({'r', 'b', 'k', 'g'}, []);
        end
        
        function test_acolor_setVectorColorCode_and_cycle_commandMode(~)
            acolor('g')     % set to something other than what we are testing
            acolor('-fast')
            genie_colors_test({'g'}, 'fast');   % check it is set
            % Test proper:
            acolor r  b  bla  g -with
            genie_colors_test({'r', 'b', 'k', 'g'}, 'with');
        end
        
        function test_acolor_setVectorColorCode_and_cycle_commandMode_ERROR(~)
            acolor('g')     % set to something other than what we are testing
            acolor('-fast')
            genie_colors_test({'g'}, 'fast');   % check it is set
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
            acolor('g')     % set to something other than what we are testing
            genie_colors_test({'g'}, []);   % check it is set
            % Test proper:
            acolor({'r', 'y', 'bla'})
            genie_colors_test({'r', 'y', 'k'}, []);
        end
        
        function test_acolor_setCellVectorColorCode_and_cycle_functionMode(~)
            acolor('g')     % set to something other than what we are testing
            acolor('-fast')
            genie_colors_test({'g'}, 'fast');   % check it is set
            % Test proper:
            acolor({'r', 'y', 'bla'}, '-wi')
            genie_colors_test({'r', 'y', 'k'}, 'with');
        end
        
        function test_acolor_singleColor_output(~)
            [col_out, cycle_out] = acolor('g', '-fa');
            assertEqual(col_out, 'green')
            assertEqual(cycle_out, 'fast')
        end
        
        function test_acolor_vectorColor_output(~)
            [col_out, cycle_out] = acolor('r', 'y', 'bla', '-wi');
            assertEqual(col_out, {'red', 'yellow', 'black'})
            assertEqual(cycle_out, 'with')
        end
        
        function test_acolor_vectorColorAndPalette_output(~)
            [col_out, cycle_out] = acolor('r', 'gem', 'bla', '-wi');
            assertEqual(col_out, {'red', 'denim', 'carrot', 'marigold', ...
                'purple', 'grass', 'babyblue', 'brickred', 'black'})
            assertEqual(cycle_out, 'with')
        end
        
        %------------------------------------------------------------------
    end
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
