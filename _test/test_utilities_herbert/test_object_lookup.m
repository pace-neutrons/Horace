classdef test_object_lookup < TestCaseWithSave
    % Test of object_lookup class
    properties
        c1
        c2
        c3
        c4
        c5
        w1
        w2
        w3
        w4
        w5
        w1norm
        w2norm
        w3norm
        w4norm
        w5norm
        carr1
        carr2
        carr3
        warr1_norm
        warr2_norm
        warr3_norm
        c_lookup1
        
        tol_dist
        seed
        rng_state
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_object_lookup (name)
            obj@TestCaseWithSave(name);
            
            % Make some test data
            c1=IX_fermi_chopper(10,150,0.049,1.3,0.003,Inf, 0, 0,50);
            c2=IX_fermi_chopper(10,250,0.049,1.3,0.003,Inf, 0, 0,100);
            c3=IX_fermi_chopper(10,350,0.049,1.3,0.003,Inf, 0, 0,300);
            c4=IX_fermi_chopper(10,450,0.049,1.3,0.003,Inf, 0, 0,400);
            c5=IX_fermi_chopper(10,550,0.049,1.3,0.003,Inf, 0, 0,350);
            
            [y,t] = pulse_shape(c1);  w1=IX_dataset_1d(t,y);
            [y,t] = pulse_shape(c2);  w2=IX_dataset_1d(t,y);
            [y,t] = pulse_shape(c3);  w3=IX_dataset_1d(t,y);
            [y,t] = pulse_shape(c4);  w4=IX_dataset_1d(t,y);
            [y,t] = pulse_shape(c5);  w5=IX_dataset_1d(t,y);
            
            w1norm = w1/c1.transmission();    % normalised to unit integral
            w2norm = w2/c2.transmission();
            w3norm = w3/c3.transmission();
            w4norm = w4/c4.transmission();
            w5norm = w5/c5.transmission();
            
            % Create object_lookup from three different arrays of objects,
            % with multiple instances of shared objects
            carr1 = [c2, c1, c4, c1, c1, c2];
            carr2 = [...
                c4, c3, c3;...
                c2, c1, c3];
            carr3 = [c3, c1];
            
            warr1_norm = [w2norm,w1norm,w4norm,w1norm,w1norm,w2norm];
            warr2_norm = [w4norm,w2norm,w3norm,w1norm,w3norm,w3norm];
            warr3_norm = [w3norm,w1norm];
            
            c_lookup1 = object_lookup({carr1,carr2,carr3});
            
            % Tolerance permitted
            obj.tol_dist = [2,0];   % allows chisqr to be as large as 3 (1 +/- 2)
            
            % Fill object
            obj.c1 = c1;
            obj.c2 = c2;
            obj.c3 = c3;
            obj.c4 = c4;
            obj.c5 = c5;
            obj.w1 = w1;
            obj.w2 = w2;
            obj.w3 = w3;
            obj.w4 = w4;
            obj.w5 = w5;
            obj.w1norm = w1norm;
            obj.w2norm = w2norm;
            obj.w3norm = w3norm;
            obj.w4norm = w4norm;
            obj.w5norm = w5norm;
            obj.carr1 = carr1;
            obj.carr2 = carr2;
            obj.carr3 = carr3;
            obj.warr1_norm = warr1_norm;
            obj.warr2_norm = warr2_norm;
            obj.warr3_norm = warr3_norm;
            obj.c_lookup1 = c_lookup1;
            
            obj.seed = 0;   % seed for random numbers at start of each test
            
            obj.save()
        end
        
        function obj = setUp(obj)
            % Save current rng state and force random seed and method
            obj.rng_state = rng(obj.seed, 'twister');
            warning('off', 'HERBERT:mask_data_for_fit:bad_points')
        end
        
        function obj = tearDown(obj)
            % Undo rng state
            rng(obj.rng_state);
            warning('on', 'HERBERT:mask_data_for_fit:bad_points')
        end
                   
        %--------------------------------------------------------------------------
        % Test basic features
        %--------------------------------------------------------------------------
        function test_recover_arrays (obj)
            % Test recovery of full arrays
            
            carr1_recover = obj.c_lookup1.object_array(1);
            carr2_recover = obj.c_lookup1.object_array(2);
            carr3_recover = obj.c_lookup1.object_array(3);
            
            assertEqual(obj.carr1, carr1_recover)
            assertEqual(obj.carr2, carr2_recover)
            assertEqual(obj.carr3, carr3_recover)
        end
        
        %--------------------------------------------------------------------------
        function test_recover_array_elements_1 (obj)
            % Test recovery of selected elements from an original array
            
            test_ref = obj.carr1([2,5,3]);
            test = obj.c_lookup1.object_elements (1, [2,5,3]);
            
            assertEqual(test_ref, test)
        end
        
        %--------------------------------------------------------------------------
        function test_recover_array_elements_2 (obj)
            % Test recovery of selected elements from an original array
            
            test_ref = obj.carr2([3,5]);
            test = obj.c_lookup1.object_elements (2, [3,5]);
            
            assertEqual(test_ref, test)
        end
        
        %--------------------------------------------------------------------------
        % Test rand_ind
        %--------------------------------------------------------------------------
        function test_random_sampling_of_distributions_1 (obj)
            % Test that randomly selected points from an array of objects 
            % stored in the object_lookup object are correctly pulled from
            % the different pdf for the different unique objects.
            
            % Get a large random array of indices in the range 1 to the number
            % of objects in one of the arrays stored in the object_lookup instance
            sz = [5e5, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr1), sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 1, ind);
            
            % Test that the distributions for each of the elements of the
            % stored array match the expected distributions
            for i=1:numel(obj.carr1)
                wtest_norm = vals2distr (xsamp(ind==i), 'norm', 'poisson');
                assertTrue (IX_dataset_1d_same (obj.warr1_norm(i), wtest_norm, ...
                    obj.tol_dist, 'rebin', 'chi'), ...
                    ['Asserted condition is not true , dataset index: ', num2str(i)]);
            end
        end
        
        
        function test_random_sampling_of_distributions_2 (obj)
            % Same as test_random_sampling_of_distributions_1 except for
            % second stored object array. This test some internal indexing
            % that picks out the correct 

            sz = [100, 5e3, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr2), sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 2, ind);
            
            % Test that the distributions for each of the elements of the
            % stored array match the expected distributions
            for i=1:numel(obj.carr2)
                wtest_norm = vals2distr (xsamp(ind==i), 'norm', 'poisson');
                assertTrue (IX_dataset_1d_same (obj.warr2_norm(i), wtest_norm, ...
                    obj.tol_dist, 'rebin', 'chi'), ...
                    ['Asserted condition is not true , dataset index: ', num2str(i)]);
            end
        end
        
        
        function test_random_sampling_of_distributions_3 (obj)
            % Same as test_random_sampling_of_distributions_1 except for
            % third stored object array.

            sz = [5e5, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr3), sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 3, ind);
            
            % Test that the distributions for each of the elements of the
            % stored array match the expected distributions
            for i=1:numel(obj.carr3)
                wtest_norm = vals2distr (xsamp(ind==i), 'norm', 'poisson');
                assertTrue (IX_dataset_1d_same (obj.warr3_norm(i), wtest_norm, ...
                    obj.tol_dist, 'rebin', 'chi'), ...
                    ['Asserted condition is not true , dataset index: ', num2str(i)]);
            end
        end
        
        
        %--------------------------------------------------------------------------
        function test_random_sampling_of_distributions_ind_sorted (obj)
            % Same as test_random_sampling_of_distributions_3 except that
            % the index array is already sorted. Follows a different branch
            % in the code.

            sz = [5e5, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr3), sz); 
            ind = reshape (sort(ind(:)), sz);
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 3, ind);
            
            % Test that the distributions for each of the elements of the
            % stored array match the expected distributions
            for i=1:numel(obj.carr3)
                wtest_norm = vals2distr (xsamp(ind==i), 'norm', 'poisson');
                assertTrue (IX_dataset_1d_same (obj.warr3_norm(i), wtest_norm, ...
                    obj.tol_dist, 'rebin', 'chi'), ...
                    ['Asserted condition is not true , dataset index: ', num2str(i)]);
            end
        end
        
        
        %--------------------------------------------------------------------------
        function test_random_sampling_of_same_distributions_not_equal (obj)
            % Check distributions generated for different elements of carr1 but same
            % underlying object are actually different. This checks that they are
            % randomly sampled separately.
            
            % Get a large random array of indices in the range 1 to the number
            % of objects in one of the arrays stored in the object_lookup instance
            sz = [1, 1e3];     % size of desired random selection of points
            ind = randselection ([2,5,4], sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 1, ind);
            
            % Test that the distributions for each of the elements of the
            % stored array match the expected distributions
            x2 = sort(xsamp(ind==2));
            x4 = sort(xsamp(ind==4));
            x5 = sort(xsamp(ind==5));
            
            assertFalse (isequal(x2,x4), 'Random samples are the same for indices 2 and 4')
            assertFalse (isequal(x4,x5), 'Random samples are the same for indices 4 and 5')
            assertFalse (isequal(x5,x2), 'Random samples are the same for indices 5 and 2')
        end

        
        %--------------------------------------------------------------------------
        % Test operation of func_eval
        %--------------------------------------------------------------------------
        function test_func_eval (obj)
            % Test operation
            ind = [6,1,5,6,1,1];    % three distinct indicies into carr2 (c)
            [tlo3, thi3] = obj.c3.pulse_range
        end
        
    end
end
