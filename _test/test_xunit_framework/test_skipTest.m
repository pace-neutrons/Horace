classdef test_skipTest < TestCase

    methods
        function self = test_skipTest(name)
            self = self@TestCase(name);
        end

        function test_skipTest_aborts_test_function(obj)
           skipTest('Skip to test function abort')
           assertFalse(true, 'SkipTest continued test function execution');
        end
    end
end
