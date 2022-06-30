classdef test_sigvar_ops1_2_Part1 < TestCaseWithSave
    % test_sigvar  Tests sigvar objects
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
        function self = test_sigvar_ops1_2_Part1 (name)
            self@TestCaseWithSave(name);
            self.save()
        end
        
        %--------------------------------------------------------------------------
        % Test adding scalar objects
        % - tests the workings of binary_op_manager_single
        %--------------------------------------------------------------------------
        function test_wscal_scal__wscal_scal (self)
            % Add scalar objects with scalar signal
            w1 = sigvar(3,25);
            w2= sigvar(4,144);
            wsum = sigvar(7,169);
            
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)

            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__wscal_1by2 (self)
            % Add scalar objects that have vector signal arrays
            w1 = sigvar([31,5],[2,3]);
            w2 = sigvar([14,16],4);
            wsum = sigvar([45,21],[6,7]);
            
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)
            
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__wscal_2by1_FAIL (self)
            % Add scalar objects that have different size signal arrays
            % *** Should throw an error
            w_1by2 = sigvar([31,5],[2,3]);
            w_2by1 = sigvar([14;16],4);
            
            testfun = @()plus(w_1by2,w_2by1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
            
            testfun = @()plus(w_2by1,w_1by2);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_scal__flt_scal (self)
            % Add scalar object with scalar signal to scalar float
            w = sigvar(3,25);
            f= 4;
            wsum = sigvar(7,25);
            
            wsum_test = w + f;
            assertEqual(wsum, wsum_test)
            
            wsum_test = f + w;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__flt_scal (self)
            % Add scalar object with vector signal to scalar float
            w = sigvar([31,5],[2,3]);
            f = 7;
            wsum = sigvar([38,12],[2,3]);
            
            wsum_test = w + f;
            assertEqual(wsum, wsum_test)
            
            wsum_test = f + w;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__flt_1by2 (self)
            % Add scalar object to float array with same size as signal array
            w = sigvar([31,5],[2,3]);
            f = [14,16];
            wsum = sigvar([45,21],[2,3]);
            
            wsum_test = w + f;
            assertEqual(wsum, wsum_test)
            
            wsum_test = f + w;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__flt_2by1_FAIL (self)
            % Add scalar object to float array with different shape to signal array
            % *** Should throw an error
            w = sigvar([31,5],[2,3]);
            f = [14;16];
            
            testfun = @()plus(w,f);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
            
            testfun = @()plus(f,w);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_1by2__flt_2by2_FAIL (self)
            % Add scalar object to float array with different size to signal array
            % Want to test that the float is *not* resolved into stack of arrays
            % *** Should throw an error
            w = sigvar([31,5],[2,3]);
            f = [14,19; 16,2];
            
            testfun = @()plus(w, f);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
            
            testfun = @()plus(f, w);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
        % Test adding arrays of objects - neither a float array
        %--------------------------------------------------------------------------
        function test_w1by3_1by2__wscal_1by2 (self)
            % Add object array to scalar object; elements with consistent signal arrays
            % 2nd object is  a scalar object
            k1 = sigvar([31,5],[2,3]);
            k2 = sigvar([14,16],4);
            k3 = sigvar([22,18],[11,12]);
            k4 = sigvar([15,14],[2,3]);
            
            w1 = [k1,k2,k3];
            w2 = k4;
            wsum = [k1+k4, k2+k4, k3+k4];
            
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)
            
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__w1by3_mixed (self)
            % Add two objects that have elements with consistent signal arrays
            % Both are objects with the same size
            k11 = sigvar([31,5],[2,3]);
            k12 = sigvar([14;16],4);
            k13 = sigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            k21 = sigvar([131,15],[2,3]);
            k22 = sigvar([24;26],3);
            k23 = sigvar([122,118,114; 29,211,-20.5],[311,312,36; 0.34,0.38,1.34]);
            
            w1 = [k11, k12, k13];
            w2 = [k21, k22, k23];
            wsum = [k11+k21, k12+k22, k13+k23];
            
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)
            
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__w1by2_mixed_FAIL (self)
            % Add two objects with inconsistent sizes
            % *** Should fail
            k11 = sigvar([31,5],[2,3]);
            k12 = sigvar([14;16],4);
            k13 = sigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            k21 = sigvar([131,15],[2,3]);
            k22 = sigvar([24;26],3);
            
            w1 = [k11, k12, k13];
            w2 = [k21, k22];
            
            testfun = @()plus(w1, w2);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager');
            
            testfun = @()plus(w2, w1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager');
        end
        
        %--------------------------------------------------------------------------
        % Test adding arrays of objects - one a float array
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__flt_scal (self)
            % Vector object, scalar float
            k11 = sigvar([31,5],[2,3]);
            k12 = sigvar([14;16],4);
            k13 = sigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            w1 = [k11,k12,k13];
            flt = 4;
            
            wsum = [k11+flt, k12+flt, k13+flt];
            
            wsum_test = w1 + flt;
            assertEqual(wsum, wsum_test)
            
            wsum_test = flt + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__flt_1by3 (self)
            % Vector object, vector float same size as object array
            k11 = sigvar([31,5],[2,3]);
            k12 = sigvar([14;16],4);
            k13 = sigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            w1 = [k11,k12,k13];
            flt = [4,5,6];
            
            wsum = [k11+flt(1), k12+flt(2), k13+flt(3)];

            wsum_test = w1 + flt;
            assertEqual(wsum, wsum_test)

            wsum_test = flt + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w3by1_mixed__flt_3by1 (self)
            % Vector object, vector float same size as object array
            k11 = sigvar([31,5],[2,3]);
            k12 = sigvar([14;16],4);
            k13 = sigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            w1 = [k11,k12,k13]';
            flt = [4,5,6]';
            
            wsum = [k11+flt(1); k12+flt(2); k13+flt(3)];

            wsum_test = w1 + flt;
            assertEqual(wsum, wsum_test)

            wsum_test = flt + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__flt_3by1_FAIL (self)
            % Vector object, vector float same number but different size as object array
            % *** Should fail as float vector has wrong shape
            k11 = sigvar([31,5],[2,3]);
            k12 = sigvar([14;16],4);
            k13 = sigvar([22,18,14; 9,11,-0.5],[11,12,6; 0.4,0.8,1.4]);
            
            w1 = [k11,k12,k13];
            flt = [4,5,6]';
            
            testfun = @()plus(w1, flt);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager');
            
            testfun = @()plus(flt, w1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager');
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_2by1__flt_2by3 (self)
            % Vector object, array float that can be resolved into stack
            k11 = sigvar([31,5]',[2,3]');
            k12 = sigvar([14,16]',4);
            k13 = sigvar([22,18]',[11,12]');
            
            w1 = [k11,k12,k13];
            flt = [4,5,6; 11,13,15];
            
            wsum = [k11+flt(:,1), k12+flt(:,2), k13+flt(:,3)];
            
            wsum_test = w1 + flt;
            assertEqual(wsum, wsum_test)
            
            wsum_test = flt + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_1by2__flt_2by3_FAIL (self)
            % Vector object, array float that can be resolved into stack
            % *** Should fail, as the objects all have the same signal sizes, but
            %     this does not match the root array size of the float
            k11 = sigvar([31,5],[2,3]);
            k12 = sigvar([14,16],4);
            k13 = sigvar([22,18],[11,12]);
            
            w1 = [k11,k12,k13];
            flt = [4,5,6; 11,13,15];
            
            testfun = @()plus(w1, flt);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
            
            testfun = @()plus(flt, w1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__flt_2by3_FAIL (self)
            % Vector object, array float that can be resolved into stack
            % *** Should fail, as the objects do not all have the same signal sizes
            k11 = sigvar([31;5],[2;3]);
            k12 = sigvar([14;16],4);
            k13 = sigvar([22,18],[11,12]);
            
            w1 = [k11,k12,k13];
            flt = [4,5,6; 11,13,15];
            
            testfun = @()plus(w1, flt);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
            
            testfun = @()plus(flt, w1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
    end
end
