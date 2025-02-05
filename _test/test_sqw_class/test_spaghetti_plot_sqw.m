classdef test_spaghetti_plot_sqw < TestCase
    % Test plotting methods on sqw and dnd objects
    properties
        sqw_obj

        rlp = [0,0,0; 0,0,1; 1,0,1; 1,1,1];
    end

    methods

        function obj = test_spaghetti_plot_sqw(varargin)
            obj@TestCase('test_spaghetti');
            proj = line_proj([1,0,0],[0,1,0],'type','rrr','alatt',pi,'angdeg',90);
            ax = proj.get_proj_axes_block(cell(4,1),{[0,0.02,1],[0,0.02,1],[0,0.02,1],[0,1,50]});
            obj.sqw_obj = sqw.generate_cube_sqw(ax,proj);
            % for testing with old Horace versions
            % obj.sqw_obj = 'd:\Data\Fe\Data\sqw\Fe_ei401.sqw';
        end
        %------------------------------------------------------------------
        function test_bad_inputs_fail(obj)

            f = @() spaghetti_plot();
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Invalid number of arguments'));

            f = @() spaghetti_plot(obj.rlp);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Invalid number of arguments'));

            f = @() spaghetti_plot(obj.rlp(1,:), obj.sqw_obj);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Array should contain at least 2 rlp'));

            f = @() spaghetti_plot(obj.rlp(:,1:2), obj.sqw_obj);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Array should contain at least 2 rlp'));

            f = @() spaghetti_plot(obj.rlp, 8);
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check argument giving data source. Must be an sqw object or sqw file'));

            f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'labels', {'A', 'B'});
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));

            f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'labels', 'A');
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));

            f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'labels', {1 2});
            err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
            assertTrue(contains(err.message, 'Check number of user-supplied labels and that they form a cell array of strings'));
        end

        function test_return_1dcuts_withpix(obj)
            [disp,cuts]=spaghetti_plot(obj.rlp, obj.sqw_obj, 'noplot','withpix');
            assertEqual(numel(disp),3)
            assertEqual(numel(cuts),3)
            assertTrue(isa(disp,'d2d'))
            assertTrue(iscell(cuts))
            assertTrue(isa(cuts{1},'sqw'))
            assertEqual(cuts{1}(1).NUM_DIMS,1)
        end

        function test_return_1dcuts_nopix(obj)
            [disp,cuts]=spaghetti_plot(obj.rlp, obj.sqw_obj, 'noplot');
            assertEqual(numel(disp),3)
            assertEqual(numel(cuts),3)
            assertTrue(isa(disp,'d2d'))
            assertTrue(iscell(cuts))
            assertTrue(isa(cuts{1},'d1d'))
        end

        function test_input_qwidth(obj)
            qwidths = {0.1
                [0.1, 0.2]
                [0.1; 0.2]
                [0.1; 0.2; 0.3]
                [0.1, 0.2, 0.3]                
                [0.1, 0.2, 0.3; 0.4, 0.5, 0.6]};

            qwl = {...
                [0.2,0.2,0.2;0.2,0.2,0.2]
                [0.2,0.2,0.2;0.4,0.4,0.4]
                [0.2,0.2,0.2;0.4,0.4,0.4]                
                [0.2,0.4,0.6;0.2,0.4,0.6]
                [0.2,0.4,0.6;0.2,0.4,0.6]                
                [0.2,0.4,0.6;0.8,1,1.2]};
            for i = 1:numel(qwidths)
                disp=spaghetti_plot(obj.rlp, obj.sqw_obj, 'qwidth', qwidths{i}, 'noplot');
                assertEqual(numel(disp),3)
                assertTrue(isa(disp,'d2d'))
                q_width = qwl{i};                
                for j=1:numel(disp)                    
                    dw = disp(j).img_range(2,:)-disp(j).img_range(1,:);
                    assertElementsAlmostEqual(dw(2:3)',q_width(1:2,j)/2); % 2 = 2*pi/pi -- inverse lattice constant
                end
            end
        end

        function test_bad_inputs_qwidth_fail(obj)
            qwidths = {[0.1; 0.2; 0.3; 0.5]       % Too many widths
                [0.1, 0.2, 0.3; 0.4, 0.5, 0.6; 0.7, 0.8, 0.9] % Too many widths
                };

            for i = 1:numel(qwidths)
                f = @() spaghetti_plot(obj.rlp, obj.sqw_obj, 'qwidth', qwidths{i}, 'noplot');
                err = assertExceptionThrown(f, 'HORACE:spaghetti_plot:invalid_argument');
                assertTrue(contains(err.message, 'qwidth size must be one of: [1, 1], [2, 1], [1, nseg] or [2, nseg] where'))
            end
        end
    end
end
