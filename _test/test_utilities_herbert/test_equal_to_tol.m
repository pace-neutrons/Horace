classdef test_equal_to_tol < TestCase

    properties
    end

    methods

        function obj = test_equal_to_tol(~)
            obj = obj@TestCase('test_equal_to_tol');
        end

        function test_equal_to_tol_var_eq_to_tol0(~)
            a = 10;
            b = 10.05;
            [ok,mess,opt] = equal_to_tol(a,b,0.1);
            assertTrue(ok)
            assertTrue(isempty(mess));
            assertEqual(opt.name_a,'a');
            assertEqual(opt.name_b,'b');
            assertEqual(opt.tol,[0.1,0]);
            assertTrue(opt.recursive_call);

            [ok,mess,opt] = equal_to_tol(a,b,opt,[0.2,0.1]);
            assertTrue(ok)
            assertTrue(isempty(mess));
            assertEqual(opt.name_a,'a');
            assertEqual(opt.name_b,'b');
            assertEqual(opt.tol,[0.2,0.1]);
            assertTrue(opt.recursive_call);
        end

        function test_equal_to_tol_var(~)
            a = 10;
            b = 20;
            [ok,mess] = equal_to_tol(a,b);
            assertFalse(ok)
            assertTrue(strncmp(mess,'a and b: Not all elements are equal;',20))
        end

        function test_equal_to_tol_numbers(~)
            [ok,mess] = equal_to_tol(10,20);
            assertFalse(ok)
            assertTrue(strncmp(mess,'input_1 and input_2: Not all elements are equal',30))
        end

    end

end
