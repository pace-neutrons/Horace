classdef test_parallel_cut < TestCase

    methods
        function obj = test_parallel_cut(name)
            if ~exist('name', 'var')
                name = 'test_parallel_cut';
            end
            obj = obj@TestCase(name);
        end

        function test_cut_cube(~)
            data = sqw.generate_cube_sqw(10);

            proj = ortho_proj([1 0 0], [0 1 0]);
            params = {[-2.5, 1, 2.5], [-5 5], [-5 5], [-5 5]};


            cut_ser = cut(data, proj, params{:});
            cut_par = parallel_call(@cut, {data, proj, params{:}});

            cut_ser
            cut_par

            assertEqualToTol(cut_ser, cut_par)

        end


    end


end
