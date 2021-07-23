classdef test_assertExceptionThrown < TestCase
    % Tests derived from _test/shared/matlab_xunit/tests/testAssertExceptionThrown.m
    % to verify additional behaviour

    methods
        function self = test_assertExceptionThrown(name)
            self = self@TestCase(name);
        end

        function test_exception_returned_when_expected_exception_is_thrown(~)
            ex = assertExceptionThrown(...
                @() error('MyProd:MyFun:MyId', 'my message'), ...
                'MyProd:MyFun:MyId');
            assertEqual(ex.message, 'my message');
            assertEqual(ex.identifier, 'MyProd:MyFun:MyId');
        end

        function test_wrong_exception_thrown(~)
            assertExceptionThrown(@() assertExceptionThrown(...
                @() error('MyProd:MyFun:MyId', 'my message'), ...
                        'MyProd:MyFun:DifferentId'), ...
                'assertExceptionThrown:wrongException');
        end

        function test_no_exception_thrown(~)
            assertExceptionThrown(@() assertExceptionThrown(@() sin(pi), 'foobar'), ...
                'assertExceptionThrown:noException');
        end
    end
end
