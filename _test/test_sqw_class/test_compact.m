classdef test_compact < TestCase

    methods
        function obj = test_compact(name)
            obj = obj@TestCase(name);
        end

        function test_compact_slice_cube_remove_dim(obj)
            data = sqw.generate_cube_sqw(10);

            test_data = cut(data, line_proj([1 0 0], [0 1 0]), ...
                            [0.2 0.05 0.7], [], [], []);

            comp = test_data.compact();

            % Check dims changed appropriately
            assertTrue(comp.data.dimensions < test_data.data.dimensions);
            assertEqual(comp.data.iax, [1]);
            assertEqual(comp.data.pax, [2 3 4]);

            % Check compacted bins subset
            for ind = 1:numel(comp.data.pax)
                ind2 = comp.data.pax(ind);
                assertTrue(all(ismember(comp.data.p{ind}, test_data.data.p{ind2})));
            end

            % Check data unchanged
            assertEqual(test_data.data.s(test_data.data.s ~= 0), comp.data.s(comp.data.s ~= 0));
            assertEqual(test_data.data.e(test_data.data.e ~= 0), comp.data.e(comp.data.e ~= 0));
            assertEqual(test_data.data.npix(test_data.data.npix ~= 0), comp.data.npix(comp.data.npix ~= 0));

        end

        function test_compact_empty_sqw(obj)
        % Check it doesn't throw
            data = sqw();
            comp = compact(data);
            assertEqualToTol(data, comp, '-ignore_date');
        end

        function test_compact_not_alter_full_data(obj)
            data = sqw.generate_cube_sqw(10);
            comp = compact(data);
            assertEqualToTol(data, comp, '-ignore_date');
        end


        function test_compact_oversized_cut(obj)
            data = sqw.generate_cube_sqw(2);
            test_data = cut(data, line_proj([1 0 0], [0 1 0]), ...
                       [-9.5 1 9.5], [-9.5 1 9.5], [-9.5 1 9.5], [-9.5 1 9.5]);

            comp = compact(test_data);

            assertEqualToTol(data, comp, '-ignore_date');

        end

    end
end
