classdef test_lower_part < TestCase
    methods
        function this=test_lower_part(varargin)
            if nargin == 0
                name = 'test_lower_part';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        function test_invalid_throw(~)
            assertExceptionThrown(@()lower_part([1,2,3;4,5,6]), ...
                'HERBERT:utilities:invalid_argument');
            mat = ones(3,3,3);
            assertExceptionThrown(@()lower_part(mat), ...
                'HERBERT:utilities:invalid_argument');
        end
        function test_lower_0empty(~)
            mat = [];
            [lp,ind] = lower_part(mat);
            assertTrue(isempty(lp));
            assertTrue(isempty(ind));
        end

        function test_lower_1empty(~)
            mat = 1;
            [lp,ind] = lower_part(mat);
            assertTrue(isempty(lp));
            assertTrue(isempty(ind));
        end
        function test_lower_3works(~)
            mat = [1,2,3;4,5,6;7,8,9];
            [lp,ind] = lower_part(mat);
            assertEqual(lp,[4;7;8])
            assertEqual(ind,[2;3;6])
        end

    end
end
