classdef test_test_gateway_to_private_folder < TestCaseWithSave
    % Test of gateway functions to access functions in class definition
    % folders, and functions and methods in the private folder in class
    % definition folders
    
    properties
        T
        a1
        a2
        a3
        b1_mi
        b2_mi
        b3_mi
        b1_m
        b2_m
        b1_mp
        b2_mp
        b1_fp
        b2_fp
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_test_gateway_to_private_folder (name)
            obj@TestCaseWithSave(name);
            
            % Make some test data
            T = testclass_for_test_gateway ('object_1',5);
            
            a1 = 3;
            a2 = 4;
            a3 = 5;
            
            % Method defined in classdef.m
            [b1_mi, b2_mi, b3_mi] = method_internal_2in_3out (T, a1, a2);
            
            % Method in the class folder as a separate file
            [b1_m, b2_m] = method_3in_2out (T, a1, a2, a3);
            
            % Method in the /private folder in the class folder as a separate file
            % Use accessor method to reach it
            [b1_mp, b2_mp] = method_private_1in_2out_accessor (T, a1);
            
            % Function in the class folder as a separate file
            % Use accessor method to reach it
            % *** THIS IS NOT ACTUALLY PERMITTED BY MATLAB
            % [b1_f, b2_f] = testclass_for_test_gateway.function_3in_2out_accessor (a1, a2, a3);
            
            % Function in the /private folder in the class folder as a separate file
            % Use accessor method to reach it
            [b1_fp, b2_fp] = testclass_for_test_gateway.function_private_1in_2out_accessor (a1);
            
            % Fill object
            obj.T = T;
            obj.a1 = a1;
            obj.a2 = a2;
            obj.a3 = a3;
            obj.b1_mi = b1_mi;
            obj.b2_mi = b2_mi;
            obj.b3_mi = b3_mi;
            obj.b1_m = b1_m;
            obj.b2_m = b2_m;
            obj.b1_mp = b1_mp;
            obj.b2_mp = b2_mp;
            obj.b1_fp = b1_fp;
            obj.b2_fp = b2_fp;
            
            obj.save()
        end
        
        %--------------------------------------------------------------------------
        function test_gateway_func_private_1 (obj)
            % Test first output only filled
            b1 = testclass_for_test_gateway.test_gateway ('function_private_1in_2out', obj.a1);
            assertEqual (b1, obj.b1_fp);
        end
        
        function test_gateway_func_private_2 (obj)
            % Test both outputs filled
            [b1, b2] = testclass_for_test_gateway.test_gateway ('function_private_1in_2out', obj.a1);
            assertEqual (b1, obj.b1_fp);
            assertEqual (b2, obj.b2_fp);
        end
        
        function test_gateway_method_private_1 (obj)
            % Test first output only filled
            b1 = testclass_for_test_gateway.test_gateway ('method_private_1in_2out', obj.T, obj.a1);
            assertEqual (b1, obj.b1_mp);
        end
        
        function test_gateway_method_private_2 (obj)
            % Test both outputs filled
            [b1, b2] = testclass_for_test_gateway.test_gateway ('method_private_1in_2out', obj.T, obj.a1);
            assertEqual (b1, obj.b1_mp);
            assertEqual (b2, obj.b2_mp);
        end
        
        %--------------------------------------------------------------------------
    end
    
end
