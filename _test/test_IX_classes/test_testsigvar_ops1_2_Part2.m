classdef test_testsigvar_ops1_2_Part2 < TestCaseWithSave
    % test_testsigvar_2  Tests testsigvar objects
    %
    % These tests add testsigvar objects and sigvar objects, as a test of
    % priorities of the objects in determining the call stack.
    %
    % Tests have a well-defined naming convention:
    %   - Objects are abbreviated in the name as the size of the object
    %     followed by the size of the signal array (or the word 'mixed'
    %     if signal arrays are not all the same size
    %       e.g. wscal_scal   wscal_1by2    w3by2_1by2    w3by2_mixed
    %
    %   - Floats are abbreviated by their size
    %       e.g. flt_scal   flt_3by4
    %
    % The tests check the symmetry of (w1 + w2) and (w2 + w1)
    
    methods
        %--------------------------------------------------------------------------
        function self = test_testsigvar_ops1_2_Part2 (name)
            self@TestCaseWithSave(name);
            self.save()
        end
        
        %--------------------------------------------------------------------------
        % Test adding scalar objects
        % - tests the workings of binary_op_manager_single
        %--------------------------------------------------------------------------
        function test_wscal_scal__wscal_scal (self)
            % Add scalar objects with scalar signal
            w1 = testsigvar(3,25);
            w2 = sigvar(4,144);
            
            wsum = testsigvar(7,169);
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)

            wsum = sigvar(7,169);   % w2 + w1 gives sigvar as the output class
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__wscal_1by2 (self)
            % Add scalar objects that have vector signal arrays
            w1 = testsigvar([31,5],[2,3]);
            w2 = sigvar([14,16],4);
            
            wsum = testsigvar([45,21],[6,7]);
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)
            
            wsum = sigvar([45,21],[6,7]);
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__wscal_2by1_FAIL (self)
            % Add scalar objects that have different size signal arrays
            % *** Should throw an error
            w_1by2 = testsigvar([31,5],[2,3]);
            w_2by1 = sigvar([14;16],4);
            
            testfun = @()plus(w_1by2,w_2by1);
            assertExceptionThrown(testfun, 'TESTSIGVAR:binary_op_manager_single');
            
            testfun = @()plus(w_2by1,w_1by2);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
        end

        
        %--------------------------------------------------------------------------
        % Test adding arrays of objects - neither a float array
        %--------------------------------------------------------------------------
        function test_w1by3_1by2__wscal_1by2 (self)
            % Add object array to scalar object; elements with consistent signal arrays
            % 2nd object is  a scalar object
            k1 = testsigvar([31,5],[2,3]);
            k2 = testsigvar([14,16],4);
            k3 = testsigvar([22,18],[11,12]);
            k4 = sigvar([15,14],[2,3]);
            
            w1 = [k1,k2,k3];
            w2 = k4;
            
            wsum = [k1+k4, k2+k4, k3+k4];
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)
            
            wsum = [k4+k1, k4+k2, k4+k3];
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__w1by3_mixed (self)
            % Add two objects that have elements with consistent signal arrays
            % Both are objects with the same size
            k11 = testsigvar([31,5],[2,3]);
            k12 = testsigvar([14;16],4);
            k13 = testsigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            k21 = sigvar([131,15],[2,3]);
            k22 = sigvar([24;26],3);
            k23 = sigvar([122,118,114; 29,211,-20.5],[311,312,36; 0.34,0.38,1.34]);
            
            w1 = [k11, k12, k13];
            w2 = [k21, k22, k23];
            
            wsum = [k11+k21, k12+k22, k13+k23];
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)
            
            wsum = [k21+k11, k22+k12, k23+k13];
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__w1by2_mixed_FAIL (self)
            % Add two objects with inconsistent sizes
            % *** Should fail
            k11 = testsigvar([31,5],[2,3]);
            k12 = testsigvar([14;16],4);
            k13 = testsigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            k21 = sigvar([131,15],[2,3]);
            k22 = sigvar([24;26],3);
            
            w1 = [k11, k12, k13];
            w2 = [k21, k22];
            
            testfun = @()plus(w1, w2);
            assertExceptionThrown(testfun, 'TESTSIGVAR:binary_op_manager');
            
            testfun = @()plus(w2, w1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager');
        end
        
        %--------------------------------------------------------------------------
    end
end
