classdef test_subdiag_elements < TestCase
    methods
        function this=test_subdiag_elements(varargin)
            if nargin == 0
                name = 'test_subdiag_elements';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        function test_invalid_throw(~)
            assertExceptionThrown(@()subdiag_elements([1,2,3;4,5,6]), ...
                'HERBERT:utilities:invalid_argument');
            mat = ones(3,3,3);
            assertExceptionThrown(@()subdiag_elements(mat), ...
                'HERBERT:utilities:invalid_argument');
        end
        function test_lower_0empty(~)
            mat = [];
            [lp,ind] = subdiag_elements(mat);
            assertTrue(isempty(lp));
            assertTrue(isempty(ind));
        end

        function test_lower_1empty(~)
            mat = 1;
            [lp,ind] = subdiag_elements(mat);
            assertTrue(isempty(lp));
            assertTrue(isempty(ind));
        end
        function test_lower_3works(~)
            mat = [1,2,3;4,5,6;7,8,9];
            [lp,ind] = subdiag_elements(mat);
            assertEqual(lp,[4;7;8])
            assertEqual(ind,[2;3;6])
        end

    end
end
