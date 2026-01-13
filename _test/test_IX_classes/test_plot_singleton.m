classdef test_plot_singleton < TestCase
    % Test genieplot singleton
    %
    % Tests the setting, getting and resetting of the properties
    %
    % In addition, tests the interoperability between the two different syntaxes
    % for use of genieplot.

    properties
        S_default       % Structure with default property values
        % store current graphics settings in the structure to revert it
        % back after test completeon.
        current_graphics_settings
    end


    methods
        function obj = test_plot_singleton(name)
            obj = obj@TestCase(name);

            % Default property values as a structure
            S.XScale = 'linear';
            S.YScale = 'linear';
            S.ZScale = 'linear';
            S.color_cycle = 'with';
            S.colors = {'k'};
            S.default_fig_name = [];
            S.line_styles = {'-'};
            S.line_widths = 0.5000;
            S.marker_sizes = 6;
            S.marker_types = {'o'};
            S.maxspec_1D = 1000;
            S.maxspec_2D = 1000;
            S.use_original_horace_plot_colours = true;

            obj.S_default = orderfields(S);
        end

        function setUp(obj)
            obj.current_graphics_settings = genieplot.get();
        end
        function tearDown(obj)
            genieplot.set(obj.current_graphics_settings);
        end

        %------------------------------------------------------------------
        %  genieplot tests - exclusively for the syntax type:
        %
        %       genieplot.set(<property_name>, <value>)
        %       val = genieplot.get('marker_sizes')
        %       S = genieplot.get()
        %       genieplot.reset()
        %
        %------------------------------------------------------------------
        function test_get_all(obj)
            % Test genieplot.get() returns a structure with the fields of genieplot

            S = genieplot.get();
            assertTrue((isstruct(S) && isscalar(S)), ...
                'Output is not a scalar structure')
            assertTrue(isequal(fieldnames(S), fieldnames(obj.S_default)), ...
                'Property names not correct')
        end


        function test_set_all(obj)
            % Test genieplot.set(S) (S a structure) works

            % Create two structures that will set different property values
            S1 = obj.S_default;    % some suitable starting set
            S2 = obj.S_default;
            S1.colors = {'k','#121314','y'};
            S2.colors = {'g','b','y'};

            % Set and then retrieve a structure (using the tested get() method)
            % Do it for two different structures to test that the retrieved
            % structures are different (i.e. something actually was set!)
            genieplot.set(S1)        % set new property values
            S1_retrieved = genieplot.get();
            genieplot.set(S2)        % set new property values
            S2_retrieved = genieplot.get();

            % Test that S1_retrieved and S2 retrieved match S1 and S2 respectively
            assertTrue((isequal(S1,S1_retrieved)), 'S1 and S1_retrieved do not match')
            assertTrue((isequal(S2,S2_retrieved)), 'S2 and S2_retrieved do not match')
        end


        function test_reset(obj)
            % Test genieplot.reset()
            genieplot.reset
            S = genieplot.get();    % get() is tested elsewhere
            assertTrue((isequal(S,obj.S_default)), 'Expected defaults not recovered')

            % Set to something else
            S1 = S;
            S1.colors = {'g','b','y'};
            genieplot.set(S1)
            assertFalse((isequal(S1,obj.S_default)), 'set to new properties failed')

            % Test reset does its job
            genieplot.reset
            S2 = genieplot.get();    % get() is tested elsewhere
            assertTrue((isequal(S2,obj.S_default)), 'Expected defaults not recovered')
        end


        %-----------------------------------------------
        function test_set_nonExistentProperty_ERROR(~)
            % Test attempting to set unrecognised property
            assertExceptionThrown(@()genieplot.set('local_only', true), ...
                'MATLAB:noPublicFieldForClass');
        end

        function test_get_nonExistentProperty_ERROR(~)
            % Test attempting to get unrecognised property
            assertExceptionThrown(@()genieplot.get('local_only'), ...
                'MATLAB:noSuchMethodOrField');
        end


        %-----------------------------------------------
        function test_setAndGet_XScale(~)
            % Test setting and getting XScale
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('XScale', 'linear')
            val = genieplot.get('XScale');
            assertEqual(val, 'linear')

            genieplot.set('XScale', 'log')
            val = genieplot.get('XScale');
            assertEqual(val, 'log')
        end

        function test_setAndGet_XScale_ERROR(~)
            % Test attempting to set invalid XScale
            assertExceptionThrown(@()genieplot.set('XScale', 'Peter'), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_YScale(~)
            % Test setting and getting YScale
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('YScale', 'linear')
            val = genieplot.get('YScale');
            assertEqual(val, 'linear')

            genieplot.set('YScale', 'log')
            val = genieplot.get('YScale');
            assertEqual(val, 'log')
        end

        function test_setAndGet_YScale_ERROR(~)
            % Test attempting to set invalid YScale
            assertExceptionThrown(@()genieplot.set('YScale', false), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_ZScale(~)
            % Test setting and getting ZScale
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('ZScale', 'linear')
            val = genieplot.get('ZScale');
            assertEqual(val, 'linear')

            genieplot.set('ZScale', 'log')
            val = genieplot.get('ZScale');
            assertEqual(val, 'log')
        end

        function test_setAndGet_ZScale_ERROR(~)
            % Test attempting to set invalid ZScale
            assertExceptionThrown(@()genieplot.set('ZScale', [34,35]), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_colors(~)
            % Test setting and getting colors
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('colors', {'b'})
            val = genieplot.get('colors');
            assertEqual(val, {'b'})

            genieplot.set('colors', {'k','#121314','y'})
            val = genieplot.get('colors');
            assertEqual(val, {'k','#121314','y'})
        end

        function test_setAndGet_colors_ERROR(~)
            % Test attempting to set invalid colors
            assertExceptionThrown(@()genieplot.set('colors', 666), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_color_cycle(~)
            % Test setting and getting color_cycle
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('color_cycle', 'with')
            val = genieplot.get('color_cycle');
            assertEqual(val, 'with')

            genieplot.set('color_cycle', 'fast')
            val = genieplot.get('color_cycle');
            assertEqual(val, 'fast')
        end

        function test_setAndGet_color_cycle_ERROR(~)
            % Test attempting to set invalid color_cycle
            assertExceptionThrown(@()genieplot.set('color_cycle', 666), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_default_fig_name(~)
            % Test setting and getting default_fig_name
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('default_fig_name', 'A silly name')
            val = genieplot.get('default_fig_name');
            assertEqual(val, 'A silly name')

            genieplot.set('default_fig_name', 'Lets boogie')
            val = genieplot.get('default_fig_name');
            assertEqual(val, 'Lets boogie')
        end

        function test_setAndGet_default_fig_name_ERROR(~)
            % Test attempting to set invalid default_fig_name
            assertExceptionThrown(@()genieplot.set('default_fig_name', 37), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_line_styles(~)
            % Test setting and getting line_styles
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('line_styles', '--')
            val = genieplot.get('line_styles');
            assertEqual(val, '--')

            genieplot.set('line_styles', {'-', '-.'})
            val = genieplot.get('line_styles');
            assertEqual(val, {'-', '-.'})
        end

        function test_setAndGet_line_styles_ERROR(~)
            % Test attempting to set invalid line_styles
            assertExceptionThrown(@()genieplot.set('line_styles', 'ddot'), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_line_widths(~)
            % Test setting and getting line_styles
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('line_widths', 1.5)
            val = genieplot.get('line_widths');
            assertEqual(val, 1.5)

            genieplot.set('line_widths', [0.4,4.6])
            val = genieplot.get('line_widths');
            assertEqual(val, [0.4,4.6])
        end

        function test_setAndGet_line_widths_ERROR(~)
            % Test attempting to set invalid line_widths
            assertExceptionThrown(@()genieplot.set('line_widths', 'thick'), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_marker_sizes(~)
            % Test setting and getting marker_sizes
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('marker_sizes', 1.5)
            val = genieplot.get('marker_sizes');
            assertEqual(val, 1.5)

            genieplot.set('marker_sizes', [0.4,4.6])
            val = genieplot.get('marker_sizes');
            assertEqual(val, [0.4,4.6])
        end

        function test_setAndGet_marker_sizes_ERROR(~)
            % Test attempting to set invalid marker_sizes
            assertExceptionThrown(@()genieplot.set('marker_sizes', 'big'), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_marker_types(~)
            % Test setting and getting marker_types
            genieplot.reset     % return to defaults

            % Check for two different set values, just in case the first
            % value is the same as the default
            genieplot.set('marker_types', '^')
            val = genieplot.get('marker_types');
            assertEqual(val, '^')

            genieplot.set('marker_types', {'+', 'p'})
            val = genieplot.get('marker_types');
            assertEqual(val, {'+', 'p'})
        end

        function test_setAndGet_marker_types_ERROR(~)
            % Test attempting to set invalid marker_types
            assertExceptionThrown(@()genieplot.set('marker_types', 'diamond'), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %-----------------------------------------------
        function test_setAndGet_maxspec_1D(~)
            % Test setting and getting maxspec_1D
            genieplot.reset     % return to defaults

            genieplot.set('maxspec_1D', 468)
            val = genieplot.get('maxspec_1D');
            assertEqual(val, 468)
        end

        function test_setAndGet_maxspec_1D_ERROR_zero(~)
            % Test attempting to set invalid maxspec_1D
            assertExceptionThrown(@()genieplot.set('maxspec_1D', 0), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_1D_ERROR_nonInteger(~)
            % Test attempting to set invalid maxspec_1D
            assertExceptionThrown(@()genieplot.set('maxspec_1D', 314.15), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_1D_ERROR_negative(~)
            % Test attempting to set invalid maxspec_1D
            assertExceptionThrown(@()genieplot.set('maxspec_1D', -3), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_1D_ERROR_negativeInf(~)
            % Test attempting to set invalid maxspec_1D
            assertExceptionThrown(@()genieplot.set('maxspec_1D', -Inf), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_1D_ERROR_NaN(~)
            % Test attempting to set invalid maxspec_1D
            assertExceptionThrown(@()genieplot.set('maxspec_1D', NaN), ...
                'HERBERT:genieplot:invalid_argument');
        end

        %-----------------------------------------------
        function test_setAndGet_maxspec_2D(~)
            % Test setting and getting maxspec_2D
            genieplot.reset     % return to defaults

            genieplot.set('maxspec_2D', 468)
            val = genieplot.get('maxspec_2D');
            assertEqual(val, 468)
        end

        function test_setAndGet_maxspec_2D_ERROR_zero(~)
            % Test attempting to set invalid maxspec_2D
            assertExceptionThrown(@()genieplot.set('maxspec_2D', 0), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_2D_ERROR_nonInteger(~)
            % Test attempting to set invalid maxspec_2D
            assertExceptionThrown(@()genieplot.set('maxspec_2D', 314.15), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_2D_ERROR_negative(~)
            % Test attempting to set invalid maxspec_2D
            assertExceptionThrown(@()genieplot.set('maxspec_2D', -3), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_2D_ERROR_negativeInf(~)
            % Test attempting to set invalid maxspec_2D
            assertExceptionThrown(@()genieplot.set('maxspec_2D', -Inf), ...
                'HERBERT:genieplot:invalid_argument');
        end

        function test_setAndGet_maxspec_2D_ERROR_NaN(~)
            % Test attempting to set invalid maxspec_2D
            assertExceptionThrown(@()genieplot.set('maxspec_2D', NaN), ...
                'HERBERT:genieplot:invalid_argument');
        end


        %------------------------------------------------------------------
        %  genieplot tests - for the syntax type:
        %
        %       g = genieplot.instance()
        %       g.<property_name> = <value>
        %       <value> = g.<property_name>
        %       g.reset()
        %
        %       and its interoperability with the genieplot.<method> syntax
        %       tested above
        %
        %------------------------------------------------------------------
        function test_setterGetterSyntax_get_instance(obj)
            % Tests that more than one instance of the singleton can be created
            % but that changing properties of one changes for the others, and
            % also the base singleton instance (tests the internal logic of the
            % singleton implementation in Matlab code)
            genieplot.reset     % reset to defaults

            % Create two instances
            a = genieplot.instance();
            b = genieplot.instance();

            % Get colors from each syntax type
            acol = a.colors;
            bcol = b.colors;
            gcol = genieplot.get('colors');

            assertTrue(isequal(gcol, obj.S_default.colors), ...
                'Base singleton ''color'' does not have the default value')
            assertTrue(isequal(acol, bcol), '''colors'' mismatch - two instances')
            assertTrue(isequal(acol, gcol), '''colors'' mismatch - with base singleton')
            assertTrue(isequal(bcol, gcol), '''colors'' mismatch - with base singleton')
        end

        function test_setterGetterSyntax_set_property(obj)
            % Tests that the property setters and getters work - set on the base
            % singleton
            genieplot.reset     % reset to defaults

            % Create two instances
            a = genieplot.instance();
            b = genieplot.instance();

            % Change the value of colors
            new_colors = {'b', 'g', 'r'};
            assertFalse(isequal(new_colors, obj.S_default.colors), ...
                'New colors are the same as the defaults - invalidates the test')
            genieplot.set('colors', new_colors);

            % Get colors from each syntax type
            acol = a.colors;
            bcol = b.colors;
            gcol = genieplot.get('colors');

            assertTrue(isequal(gcol, new_colors), ...
                'Base singleton ''color'' does not have the expected value')
            assertTrue(isequal(acol, bcol), '''colors'' mismatch - two instances')
            assertTrue(isequal(acol, gcol), '''colors'' mismatch - with base singleton')
            assertTrue(isequal(bcol, gcol), '''colors'' mismatch - with base singleton')
        end

        function test_setterGetterSyntax_set_property_on_an_instance(obj)
            % Tests that the property setters and getters work - set on an
            % instance of the singleton
            genieplot.reset     % reset to defaults

            % Create two instances
            a = genieplot.instance();
            b = genieplot.instance();

            % Change the value of colors
            new_colors = {'b', 'g', 'r'};
            assertFalse(isequal(new_colors, obj.S_default.colors), ...
                'New colors are the same as the defaults - invalidates the test')
            a.colors = new_colors;

            % Get colors from each syntax type
            acol = a.colors;
            bcol = b.colors;
            gcol = genieplot.get('colors');

            assertTrue(isequal(gcol, new_colors), ...
                'Base singleton ''color'' does not have the expected value')
            assertTrue(isequal(acol, bcol), '''colors'' mismatch - two instances')
            assertTrue(isequal(acol, gcol), '''colors'' mismatch - with base singleton')
            assertTrue(isequal(bcol, gcol), '''colors'' mismatch - with base singleton')
        end

        function test_setterGetterSyntax_reset(obj)
            % Tests that reset acting on the base singleton properly resets the
            % values of all instances of the singleton to the default values
            genieplot.reset     % reset to defaults

            % Create two instances
            a = genieplot.instance();
            b = genieplot.instance();

            % Change the value of colors
            % (This operation has been tested to work in a separate unit test)
            new_colors = {'b', 'g', 'r'};
            assertFalse(isequal(new_colors, obj.S_default.colors), ...
                'New colors are the same as the defaults - invalidates the test')
            a.colors = new_colors;  % this has been tests

            % Reset the singleton to default value
            genieplot.reset     % reset to defaults - directly on singleton

            % Get colors from each syntax type
            acol = a.colors;
            bcol = b.colors;
            gcol = genieplot.get('colors');

            assertTrue(isequal(gcol, obj.S_default.colors), ...
                'Base singleton ''color'' does not have the expected value')
            assertTrue(isequal(acol, bcol), '''colors'' mismatch - two instances')
            assertTrue(isequal(acol, gcol), '''colors'' mismatch - with base singleton')
            assertTrue(isequal(bcol, gcol), '''colors'' mismatch - with base singleton')
        end

        function test_setterGetterSyntax_reset_on_an_instance(obj)
            % Tests that reset acting on an instance properly resets the values
            % of all instances of the singleton to the default values
            genieplot.reset     % reset to defaults

            % Create two instances
            a = genieplot.instance();
            b = genieplot.instance();

            % Change the value of colors
            % (This operation has been tested to work in a separate unit test)
            new_colors = {'b', 'g', 'r'};
            assertFalse(isequal(new_colors, obj.S_default.colors), ...
                'New colors are the same as the defaults - invalidates the test')
            a.colors = new_colors;  % this has been tests

            % Reset the singleton to default value
            a.reset     % reset to defaults - act on an instance

            % Get colors from each syntax type
            acol = a.colors;
            bcol = b.colors;
            gcol = genieplot.get('colors');

            assertTrue(isequal(gcol, obj.S_default.colors), ...
                'Base singleton ''color'' does not have the expected value')
            assertTrue(isequal(acol, bcol), '''colors'' mismatch - two instances')
            assertTrue(isequal(acol, gcol), '''colors'' mismatch - with base singleton')
            assertTrue(isequal(bcol, gcol), '''colors'' mismatch - with base singleton')
        end

        function test_clear_instances(~)
            % Tests that clearing all instances created by :
            %   >> a = genieplot.instance()
            % does not clear the base singleton
            genieplot.reset     % reset to defaults
            default_colors = genieplot.get('colors');

            % Create two instances
            a = genieplot.instance();
            b = genieplot.instance();

            % Change the value of colors
            % (This operation has been tested to work in a separate unit test)
            new_colors = {'b', 'g', 'r'};
            assertFalse(isequal(new_colors, default_colors), ...
                'New colors are the same as the defaults - invalidates the test')
            a.colors = new_colors;  % this has been tested elsewhere to work

            % Clear instances
            clear a b

            % Get colors using genieplot static method - they should be the
            % colors that have been set to something different to the default
            colors = genieplot.get('colors');
            assertTrue(isequal(colors, new_colors), 'Singleton was incorrectly reset')
        end

        function test_clear_instances_and_genieplot(~)
            % Tests that clearing all instances created by :
            %   >> a = genieplot.instance()
            % does not clear the base singleton
            genieplot.reset     % reset to defaults
            default_colors = genieplot.get('colors');

            % Create two instances
            a = genieplot.instance();
            b = genieplot.instance();

            % Change the value of colors
            % (This operation has been tested to work in a separate unit test)
            new_colors = {'b', 'g', 'r'};
            assertFalse(isequal(new_colors, default_colors), ...
                'New colors are the same as the defaults - invalidates the test')
            a.colors = new_colors;  % this has been tested elsewhere to work

            % Clear instances AND genieplot - the latter should reset the
            % properties to the defaults whenever a property is sought.
            clear a b genieplot

            % Get colors using genieplot static method - they should be the
            % colors that have been set to something different to the default
            colors = genieplot.get('colors');
            assertTrue(isequal(colors, default_colors), 'Singleton was incorrectly reset')
        end


        %------------------------------------------------------------------
    end
end
