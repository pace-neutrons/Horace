classdef test_IX_dataset_1d_ops1_2_Part1 < TestCaseWithSave
    %
    % These tests add IX_dataset_1d objects to themselves or floats, as a test
    % of the operation of the underlying calls to sigvar methods.
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
        function self = test_IX_dataset_1d_ops1_2_Part1 (name)
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
            w2 = self.p2;
            
            s = w1.signal + w2.signal;
            e = sqrt((w1.error).^2 + (w2.error).^2);
            
            wsum = w1; wsum.signal=s; wsum.error=e;
            wsum_test = w1 + w2;
            assertEqual(wsum, wsum_test)

            wsum = w2; wsum.signal=s; wsum.error=e;
            wsum_test = w2 + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_20by1__wscal_516by1_FAIL (self)
            % Add scalar objects that have different size signal arrays
            % *** Should throw an error
            w1 = self.p1;
            w2 = self.pbig;
            
            testfun = @()plus(w1,w2);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
            
            testfun = @()plus(w2,w1);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_20by1__flt_scal (self)
            % Add scalar object to scalar float
            w = self.p1;
            f= 4;
            
            wsum = w; wsum.signal=w.signal + 4;
            
            wsum_test = w + f;
            assertEqual(wsum, wsum_test)
            
            wsum_test = f + w;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_20by1__flt_20by1 (self)
            % Add scalar object to float array with same size as signal array
            w = self.p1;
            f = rand(size(w.signal));
            
            wsum = w; wsum.signal=w.signal + f;
            
            wsum_test = w + f;
            assertEqual(wsum, wsum_test)
            
            wsum_test = f + w;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_20by1__flt_1by20_FAIL (self)
            % Add scalar object to float array with different shape to signal array
            % *** Should throw an error
            w = self.p1;
            f = rand(size(w.signal))';
            
            testfun = @()plus(w,f);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
            
            testfun = @()plus(f,w);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
        function test_wscal_20by1__flt_20by20_FAIL (self)
            % Add scalar object to float array with different size to signal array
            % Want to test that the float is *not* resolved into stack of arrays
            % *** Should throw an error
            w = self.p1;
            f = rand(numel(w.signal), numel(w.signal));
            
            testfun = @()plus(w, f);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
            
            testfun = @()plus(f, w);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
        % Test adding arrays of objects - neither a float array
        %--------------------------------------------------------------------------
        function test_w1by3_20by1__wscal_20by1 (self)
            % Add object array to scalar object; elements with consistent signal arrays
            % 2nd object is  a scalar object
            k1 = self.p1;
            k2 = self.p2;
            k3 = self.p3;
            k4 = self.h1;
            
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
            
            k21 = self.h1;
            k22 = self.h2;
            k23 = self.hbig;
            
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
            
            k21 = self.h1;
            k22 = self.h2;
            
            w1 = [k11, k12, k13];
            w2 = [k21, k22];
            
            testfun = @()plus(w1, w2);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager');
            
            testfun = @()plus(w2, w1);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager');
        end
        
        %--------------------------------------------------------------------------
        % Test adding arrays of objects - one a float array
        %--------------------------------------------------------------------------
        function test_w1by3_mixed__flt_scal (self)
            % Vector object, scalar float
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.pbig;
            
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
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.pbig;
            
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
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.pbig;
            
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
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.pbig;
            
            w1 = [k11,k12,k13];
            flt = [4,5,6]';
            
            testfun = @()plus(w1, flt);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager');
            
            testfun = @()plus(flt, w1);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager');
        end
        
        %--------------------------------------------------------------------------
        function test_w1by3_20by1__flt_20by3 (self)
            % Vector object, array float that can be resolved into stack
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.p3;
            
            w1 = [k11,k12,k13];
            flt = rand(numel(k11.signal), 3);
            
            wsum = [k11+flt(:,1), k12+flt(:,2), k13+flt(:,3)];
            
            wsum_test = w1 + flt;
            assertEqual(wsum, wsum_test)
            
            wsum_test = flt + w1;
            assertEqual(wsum, wsum_test)
        end
        
        %--------------------------------------------------------------------------
        function test_w20by3_mixed__flt_20by3_FAIL (self)
            % Vector object, array float that can be resolved into stack
            % *** Should fail, as the objects do not all have the same signal sizes
            k11 = self.p1;
            k12 = self.p2;
            k13 = self.pbig;
            
            w1 = [k11,k12,k13];
            flt = rand(numel(k11.signal), 3);
            
            testfun = @()plus(w1, flt);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
            
            testfun = @()plus(flt, w1);
            assertExceptionThrown(testfun, 'IX_DATASET:binary_op_manager_single');
        end
        
        %--------------------------------------------------------------------------
    end
end
