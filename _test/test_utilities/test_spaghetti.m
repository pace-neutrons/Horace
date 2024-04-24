classdef test_spaghetti < TestCase

    properties
        win = sqw.generate_cube_sqw(10);
        rlp = [0,0,0; 0,0,1; 1,0,1; 1,0,0];
    end

    methods
        function obj = test_spaghetti(~)
            obj@TestCase('test_spaghetti');
        end

        function test_bad_inputs_fail(obj)

            f = @() spaghetti_plot();
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Invalid number of arguments'));

            f = @() spaghetti_plot(obj.rlp);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Invalid number of arguments'));

            f = @() spaghetti_plot(obj.rlp(1,:), obj.win);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Array should contain at least 2 rlp'));

            f = @() spaghetti_plot(obj.rlp(:,1:2), obj.win);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Array should contain at least 2 rlp'));

            f = @() spaghetti_plot(obj.rlp, 8);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check argument giving data source. Must be an sqw object or sqw file'));

            f = @() spaghetti_plot(obj.rlp, obj.win, 'labels', {'A', 'B'});
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));

            f = @() spaghetti_plot(obj.rlp, obj.win, 'labels', 'A');
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));

            f = @() spaghetti_plot(obj.rlp, obj.win, 'labels', {1 2});
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));
        end

        function test_input_qwidth(obj)
            qwidths = {0.1
                       [0.1, 0.2]
                       [0.1; 0.2]
                       [0.1; 0.2; 0.3]
                       [0.1, 0.2, 0.3; 0.4, 0.5, 0.6]};

            for i = 1:numel(qwidths)
                spaghetti_plot(obj.rlp, obj.win, 'qwidth', qwidths{i}, 'noplot');
            end
        end

        function test_bad_inputs_qwidth_fail(obj)
            qwidths = {[0.1; 0.2; 0.3; 0.5]                          % Too many widths
                       [0.1, 0.2, 0.3; 0.4, 0.5, 0.6; 0.7, 0.8, 0.9] % Too many widths
                      };

            for i = 1:numel(qwidths)
                f = @() spaghetti_plot(obj.rlp, obj.win, 'qwidth', qwidths{i}, 'noplot');
                err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
                assertTrue(contains(err.message, 'qwidth size must be one of: [1, 1], [2, 1], [1, nseg], or [2, nseg].'))
            end

        end
    end
end
