classdef test_IX_dataset_1d_ops1_2_Part2 < TestCaseWithSave
    % test_testsigvar_2  Tests testsigvar objects
    %
    % These tests add IX_dataset_1d objects and sigvar objects, as a test of
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
    
    properties
        % Three point data datasets, all same number of data points
        p1
        p2
        p3
        % Three histogram data datasets, all same number of data points
        % as the point datasets above
        h1
        h2
        h3
        % Point and histogram datasets same number points but more than above
        pbig
        hbig
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_IX_dataset_1d_ops1_2_Part2 (name)
            self@TestCaseWithSave(name);
            
            % Load some test data
            S = load('testdata_IX_datasets_ref.mat');
            
            % Three point data datasets, all same number of data points
            self.p1 = S.p1;
            self.p2 = S.p2;
            self.p3 = S.p3;
                        
            % Three histogram data datasets, all same number of data points
            % as the point datasets above
            self.h1 = S.h1;
            self.h2 = S.h2;
            self.h3 = S.h3;
            
            % Point and histogram datasets, same number of data points
            % but many more than the the trio defined above
            self.pbig = S.pp_1d_big(1);
            self.hbig = S.hh_1d_big(1);

            self.save()
        end
        
        %--------------------------------------------------------------------------
        % Test adding scalar objects
        % - tests the workings of binary_op_manager_single
        %--------------------------------------------------------------------------
        function test_wscal_20by1__wscal_20by1 (self)
            % Add scalar objects
            w1 = self.p1;
            w2 = sigvar(rand(size(w1.signal)), rand(size(w1.error)));
            
            s = w1.signal + w2.s;
            var = (w1.error).^2 + w2.e;
            
            wsum = w1; wsum.signal=s; wsum.error=sqrt(var);
            
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)

            wsum = sigvar(s, var);   % w2 + w1 gives sigvar as the output class
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_20by1__wscal_21by1_FAIL (self)
            % Add scalar objects that have different size signal arrays
            % *** Should throw an error
            w1 = self.p1;
            w2 = sigvar(rand(size(w1.signal)+1), rand(size(w1.error)+1));
            
            testfun = @()plus(w1,w2);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
            
            testfun = @()plus(w2,w1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager_single');
        end

        
        %--------------------------------------------------------------------------
        % Test adding arrays of objects - neither a float array
        %--------------------------------------------------------------------------
        function test_w1by3_1by2__wscal_1by2 (self)
            % Add object array to scalar object; elements with consistent signal arrays
            % 2nd object is  a scalar object
            k1 = self.p1;
            k2 = self.p2;
            k3 = self.p3;
            k4 = sigvar(rand(size(k1.signal)), rand(size(k1.error)));
            
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
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.pbig;
            
            k21 = sigvar(rand(size(k11.signal)), rand(size(k11.error)));
            k22 = sigvar(rand(size(k12.signal)), rand(size(k12.error)));
            k23 = sigvar(rand(size(k13.signal)), rand(size(k13.error)));
            
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
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.pbig;
            
            k21 = sigvar(rand(size(k11.signal)), rand(size(k11.error)));
            k22 = sigvar(rand(size(k12.signal)), rand(size(k12.error)));
            
            w1 = [k11, k12, k13];
            w2 = [k21, k22];
            
            testfun = @()plus(w1, w2);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager');
            
            testfun = @()plus(w2, w1);
            assertExceptionThrown(testfun, 'SIGVAR:binary_op_manager');
        end
        
        %--------------------------------------------------------------------------
    end
end
