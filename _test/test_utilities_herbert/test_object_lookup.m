classdef test_object_lookup < TestCase
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
        warr4_norm
        warr5_norm
        c_lookup1
        c_lookup2
        
        tol_dist
        seed
        rng_state
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_object_lookup (name)
            obj = obj@TestCase(name);
            
            % Make some test data
            c1=IX_fermi_chopper(10, 150, 0.049, 1.3, 0.003, Inf, 0, 0, 50, 1, 0, 'Chopper 1');
            c2=IX_fermi_chopper(10, 250, 0.049, 1.3, 0.003, Inf, 0, 0, 100, 1, 0, 'Chopper 2');
            c3=IX_fermi_chopper(10, 350, 0.049, 1.3, 0.003, Inf, 0, 0, 300, 1, 0, 'Chopper 3');
            c4=IX_fermi_chopper(10, 450, 0.049, 1.3, 0.003, Inf, 0, 0, 400, 1, 0, 'Chopper 4');
            c5=IX_fermi_chopper(10, 550, 0.049, 1.3, 0.003, Inf, 0, 0, 350, 1, 0, 'Chopper 5');
            
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
            
            % Create a second object_lookup
            carr4 = [c4, c2, c4, c4, c5];
            carr5 = [c3, c1; c4, c4; c2, c5];
            
            warr4_norm = [w4norm,w2norm,w4norm,w4norm,w5norm];
            warr5_norm = [w3norm,w4norm,w2norm,w1norm,w4norm,w5norm];
            
            c_lookup2 = object_lookup({carr4,carr3,carr1,carr5});
            
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
            obj.warr4_norm = warr4_norm;
            obj.warr5_norm = warr5_norm;
            obj.c_lookup1 = c_lookup1;
            obj.c_lookup2 = c_lookup2;
            
            obj.seed = 0;   % seed for random numbers at start of each test
        end
        
        function obj = setUp(obj)
            % Save current rng state and force random seed and method
            obj.rng_state = rng(obj.seed, 'twister');
        end
        
        function obj = tearDown(obj)
            % Undo rng state
            rng(obj.rng_state);
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
        function test_recover_array_elements_1D_1 (obj)
            % Test recovery of selected elements from an original vector
            % carr1 is a row vector
            
            test_ref = obj.carr1([2,5,3]);
            test = obj.c_lookup1.object_elements (1, [2,5,3]);
            
            assertEqual(test_ref, test)
        end
        
        %--------------------------------------------------------------------------
        function test_recover_array_elements_1D_2 (obj)
            % Test recovery of selected elements from an original vector
            % carr1 is a row vector
            
            test_ref = obj.carr1([2,5,3]');
            test = obj.c_lookup1.object_elements (1, [2,5,3]');
            
            assertEqual(test_ref, test)
        end
        
        %--------------------------------------------------------------------------
        function test_recover_array_elements_1D_3 (obj)
            % Test recovery of selected elements from an original vector
            % carr1 is a row vector
            
            ind = [2,5,3,1;4,5,4,2];
            test_ref = obj.carr1(ind);
            test = obj.c_lookup1.object_elements (1, [2,5,3,1;4,5,4,2]);
            
            assertEqual(test_ref, test)
        end
        
        %--------------------------------------------------------------------------
        function test_recover_array_elements_2D_1 (obj)
            % Test recovery of selected elements from an original 2D array
            % carr1 is an array size (2,3)
            
            ind = [3,1,6,1];
            test_ref = obj.carr2(ind);
            test = obj.c_lookup1.object_elements (2, ind);
            
            assertEqual(test_ref, test)
        end
        
        %--------------------------------------------------------------------------
        function test_construct_nobj_1_nrep_1 (obj)
            % Repeat input object array using implicit repmat
            
            Lref = object_lookup(obj.carr1);
            [ok, mess] = check_size_and_type (Lref);
            assertTrue(ok, mess)

            Lref_nelmts = numel(obj.carr1);
            Lref_sz = {size(obj.carr1)};
            assertEqual(Lref.narray, 1)
            assertEqual(Lref.nelmts, Lref_nelmts)
            assertEqual(Lref.sz, Lref_sz)
            
            sz1 = [3,2];    % increase size of the input object array
            L = object_lookup(obj.carr1, 'repeat', sz1);
            [ok, mess] = check_size_and_type (L);
            assertTrue(ok, mess)
            
            expand_indx = @(indx,sz,szrep)(make_column(repmat(reshape(indx,sz),szrep)));
            assertEqual(L.object_store, Lref.object_store)
            assertEqual(L.indx{1}, expand_indx(Lref.indx{1}, Lref.sz{1}, sz1))
            assertEqual(L.narray, 1)
            assertEqual(L.nelmts, prod(sz1)*Lref_nelmts)
            assertEqual(L.sz{1}, size(repmat(ones(Lref_sz{1}),sz1)))

        end
        
        %--------------------------------------------------------------------------
        function test_construct_nobj_1_nrep_2 (obj)
            % Repeat input object array using multiple implicit repmat
            
            Lref = object_lookup(obj.carr1);
            [ok, mess] = check_size_and_type (Lref);
            assertTrue(ok, mess)

            Lref_nelmts = numel(obj.carr1);
            Lref_sz = size(obj.carr1);
                     
            sz1 = [3,2];
            sz2 = [5,2,4];
            sz12 = {sz1,sz2};    % create two increased-size input object arrays
            L = object_lookup(obj.carr1, 'repeat', sz12);
            [ok, mess] = check_size_and_type (L);
            assertTrue(ok, mess)
            
            expand_indx = @(indx,sz,szrep)(make_column(repmat(reshape(indx,sz),szrep)));
            assertEqual(L.object_store, Lref.object_store)
            assertEqual(L.indx{1}, expand_indx(Lref.indx{1}, Lref.sz{1}, sz1))
            assertEqual(L.indx{2}, expand_indx(Lref.indx{1}, Lref.sz{1}, sz2))
            assertEqual(L.narray, 2)
            assertEqual(L.nelmts, [prod(sz1);prod(sz2)]*Lref_nelmts)
            assertEqual(L.sz{1}, size(repmat(ones(Lref_sz),sz1)))
            assertEqual(L.sz{2}, size(repmat(ones(Lref_sz),sz2)))
            
        end

        %--------------------------------------------------------------------------
        function test_construct_nobj_2_nrep_1 (obj)
            % Repeat multiple input object arrays using implicit repmat
            
            Lref = object_lookup({obj.carr1, obj.carr2});
            [ok, mess] = check_size_and_type (Lref);
            assertTrue(ok, mess)

            Lref_nelmts = [numel(obj.carr1),numel(obj.carr2)]';
            Lref_sz = {size(obj.carr1), size(obj.carr2)}';
            assertEqual(Lref.narray, 2)
            assertEqual(Lref.nelmts, Lref_nelmts)
            assertEqual(Lref.sz, Lref_sz)
            
            sz1 = [3,2];    % increase size of the input object array
            L = object_lookup({obj.carr1, obj.carr2}, 'repeat', sz1);
            [ok, mess] = check_size_and_type (L);
            assertTrue(ok, mess)
            
            expand_indx = @(indx,sz,szrep)(make_column(repmat(reshape(indx,sz),szrep)));
            assertEqual(L.object_store, Lref.object_store)
            assertEqual(L.indx{1}, expand_indx(Lref.indx{1}, Lref.sz{1}, sz1))
            assertEqual(L.indx{2}, expand_indx(Lref.indx{2}, Lref.sz{2}, sz1))
            assertEqual(L.narray, 2)
            assertEqual(L.nelmts, prod(sz1).*Lref_nelmts)
            assertEqual(L.sz{1}, size(repmat(ones(Lref_sz{1}),sz1)))
            assertEqual(L.sz{2}, size(repmat(ones(Lref_sz{2}),sz1)))

        end
        
        %--------------------------------------------------------------------------
        function test_construct_nobj_2_nrep_2 (obj)
            % Repeat multiple input object array using multiple implicit repmat
            
            Lref = object_lookup({obj.carr1, obj.carr2});
            [ok, mess] = check_size_and_type (Lref);
            assertTrue(ok, mess)

            Lref_nelmts = [numel(obj.carr1),numel(obj.carr2)]';
            Lref_sz = {size(obj.carr1), size(obj.carr2)}';
            
            sz1 = [3,2];
            sz2 = [5,2,4];
            sz12 = {sz1,sz2};    % create two increased-size input object arrays
            L = object_lookup({obj.carr1, obj.carr2}, 'repeat', sz12);
            [ok, mess] = check_size_and_type (L);
            assertTrue(ok, mess)
            
            expand_indx = @(indx,sz,szrep)(make_column(repmat(reshape(indx,sz),szrep)));
            assertEqual(L.object_store, Lref.object_store)
            assertEqual(L.indx{1}, expand_indx(Lref.indx{1}, Lref.sz{1}, sz1))
            assertEqual(L.indx{2}, expand_indx(Lref.indx{2}, Lref.sz{2}, sz2))
            assertEqual(L.narray, 2)
            assertEqual(L.nelmts, [prod(sz1);prod(sz2)].*Lref_nelmts)
            assertEqual(L.sz{1}, size(repmat(ones(Lref_sz{1}),sz1)))
            assertEqual(L.sz{2}, size(repmat(ones(Lref_sz{2}),sz2)))

        end
        
        %--------------------------------------------------------------------------
        % Test save and load
        %--------------------------------------------------------------------------
        function test_save_then_load_equality_scalar (obj)
            % Test save then reload of a scalar object_lookup object (which itself
            % contains several array of arrays)
            chopper_lookup1 = obj.c_lookup1;
            
            % Save detector bank
            test_file = fullfile (tmp_dir(), 'test_object_lookup_save_load_scalar.mat');
            cleanup = onCleanup(@()delete(test_file));
            save (test_file, 'chopper_lookup1');
            
            % Recover detector bank
            tmp = load (test_file);
            
            assertEqual (chopper_lookup1, tmp.chopper_lookup1)
        end
        
        function test_save_then_load_equality_arr (obj)
            % Test save then reload of an array of  object_lookup objects
            % (each element of which contains several array of arrays)
            chopper_lookup1 = obj.c_lookup1;
            chopper_lookup2 = obj.c_lookup2;
            chopper_lookup = [chopper_lookup1, chopper_lookup2];
            
            % Save detector bank
            test_file = fullfile (tmp_dir(), 'test_object_lookup_save_load_arr.mat');
            cleanup = onCleanup(@()delete(test_file));
            save (test_file, 'chopper_lookup');
            
            % Recover detector bank
            tmp = load (test_file);
            
            assertEqual (chopper_lookup, tmp.chopper_lookup)
        end
        
        %--------------------------------------------------------------------------
        % Test rand_ind
        %--------------------------------------------------------------------------
        function test_random_sampling_of_distributions_arr1 (obj)
            % Test that a large set of random samples drawn from the probability 
            % distribution functions (PDFs) for an array of objects 
            % stored in the object_lookup object are pulled from
            % the correct PDFs for the different unique objects held in that
            % object_lookup object.
            
            % Get a large random array of indices in the range 1 to the number
            % of objects in one of the arrays stored in the object_lookup instance
            sz = [5e5, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr1), sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 1, ind, @rand);
            
            % Test that the distributions for each of the elements of the
            % stored array match the expected distributions
            for i=1:numel(obj.carr1)
                wtest_norm = vals2distr (xsamp(ind==i), 'norm', 'poisson');
                assertTrue (IX_dataset_1d_same (obj.warr1_norm(i), wtest_norm, ...
                    obj.tol_dist, 'rebin', 'chi'), ...
                    ['Asserted condition is not true , dataset index: ', num2str(i)]);
            end
        end
        
        
        function test_random_sampling_of_distributions_arr2 (obj)
            % Same as test_random_sampling_of_distributions_arr1 except now 
            % performed for the second stored object array. This test some
            % internal indexing that picks out the correct array

            sz = [100, 5e3, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr2), sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 2, ind, @rand);
            
            % Test that the distributions for each of the elements of the
            % stored array match the expected distributions
            for i=1:numel(obj.carr2)
                wtest_norm = vals2distr (xsamp(ind==i), 'norm', 'poisson');
                assertTrue (IX_dataset_1d_same (obj.warr2_norm(i), wtest_norm, ...
                    obj.tol_dist, 'rebin', 'chi'), ...
                    ['Asserted condition is not true , dataset index: ', num2str(i)]);
            end
        end
        
        
        function test_random_sampling_of_distributions_arr3 (obj)
            % Same as test_random_sampling_of_distributions_1 except for
            % third stored object array.

            sz = [5e5, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr3), sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 3, ind, @rand);
            
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
        function test_random_sampling_of_distributions_arr3_indSorted (obj)
            % Same as test_random_sampling_of_distributions_3 except that
            % the index array is already sorted. Follows a different branch
            % in the code.

            sz = [5e5, 10];     % size of desired random selection of points
            ind = randselection (1:numel(obj.carr3), sz); 
            ind = reshape (sort(ind(:)), sz);
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 3, ind, @rand);
            
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
            % Check generated values are actually different for different elements
            % of carr1 but which have the same underlying object . This checks that
            % they are randomly sampled separately.
            
            % Get a large random array of indices in the range 1 to the number
            % of objects in one of the arrays stored in the object_lookup instance
            sz = [1, 1e3];     % size of desired random selection of points
            ind = randselection ([2,5,4], sz); 
            
            % Create array of random values
            xsamp = rand_ind (obj.c_lookup1, 1, ind, @rand);
            
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
        % Test operation of func_eval_ind
        %--------------------------------------------------------------------------
        function test_func_eval_ind_singleUniqueObject (obj)
            % Function evaluated for an array of what corresponds to a single unique object
            % Also checks size of output arrays match the size of the index array ind
            ind = [6,3,5,6,3,3,3];    % indices into carr2 = [c4, c3, c3; c2, c1, c3];
            [tlo_ref, thi_ref] = obj.c3.pulse_range;
            tlo_ref = repmat (tlo_ref, size(ind));
            thi_ref = repmat (thi_ref, size(ind));
            
            [tlo, thi] = func_eval_ind(obj.c_lookup1, 2, ind, @pulse_range);
            assertEqual (tlo_ref, tlo)
            assertEqual (thi_ref, thi)
        end
        
        function test_func_eval_ind_threeUniqueObjects (obj)
            % Function evaluated for an array of objects that corresponds to more than
            % one unique object, but which are not all unique.
            % Also checks size of output arrays match the size of the index array ind
            ind = [6,1; 5,2; 1,1];    % indices into carr2 = [c4, c3, c3; c2, c1, c3];
            tlo_ref = zeros(size(ind));
            thi_ref = zeros(size(ind));
            [tlo_ref(1,1), thi_ref(1,1)] = obj.c3.pulse_range;
            [tlo_ref(1,2), thi_ref(1,2)] = obj.c4.pulse_range;
            [tlo_ref(2,1), thi_ref(2,1)] = obj.c3.pulse_range;
            [tlo_ref(2,2), thi_ref(2,2)] = obj.c2.pulse_range;
            [tlo_ref(3,1), thi_ref(3,1)] = obj.c4.pulse_range;
            [tlo_ref(3,2), thi_ref(3,2)] = obj.c4.pulse_range;
            
            [tlo, thi] = func_eval_ind(obj.c_lookup1, 2, ind, @pulse_range);
            assertEqual (tlo_ref, tlo)
            assertEqual (thi_ref, thi)
        end
        
        function test_func_eval_ind_rowInd_rowStack (obj)
            % Test the output argument
            % Stack [1,10] by [1,5] should be [1,10,5]
            
            sz_output = [1,10];
            ind = [5,1,1,5,3];  % indices into carr2 = [c4, c3, c3; c2, c1, c3];
            
            t = time_array (obj.c4, sz_output);     % a suitable array of times
            y3 = obj.c3.pulse_shape(t);
            y4 = obj.c4.pulse_shape(t);
            y_ref = zeros(1,10,5);
            y_ref(:,:,1) = y3;
            y_ref(:,:,2) = y4;
            y_ref(:,:,3) = y4;
            y_ref(:,:,4) = y3;
            y_ref(:,:,5) = y3;
            
            yout = func_eval_ind(obj.c_lookup1, 2, ind, @pulse_shape, t);
            assertEqual (size(yout), [1,10,5])
            assertEqual (y_ref, yout)
        end
        
        function test_func_eval_ind_rowInd_colStack (obj)
            % Test the output argument arrays
            % Stack [10,1] by [1,5] should be [10,5]
            
            sz_output = [10,1];
            ind = [5,1,1,5,3];  % indices into carr2 = [c4, c3, c3; c2, c1, c3];
            
            t = time_array (obj.c4, sz_output);     % a suitable array of times
            t_ref = repmat(t, [1,5]);
            
            y3 = obj.c3.pulse_shape(t);
            y4 = obj.c4.pulse_shape(t);
            y_ref = [y3,y4,y4,y3,y3];
            
            [yout, tout] = func_eval_ind(obj.c_lookup1, 2, ind, @pulse_shape, t);
            assertEqual (size(tout), [10,5])
            assertEqual (size(yout), [10,5])
            assertEqual (t_ref, tout)
            assertEqual (y_ref, yout)
        end
        
        function test_func_eval_ind_arrInd_colStack (obj)
            % Test the output argument arrays
            % Stack [10,1] by [1,1,5] should be [10,1,5]
            
            sz_output = [10,1];
            ind = zeros(1,1,5);
            ind(1,1,:) = [5,1,1,5,3];  % indices into carr2 = [c4, c3, c3; c2, c1, c3];
            
            t = time_array (obj.c4, sz_output);     % a suitable array of times
            t_ref = repmat(t, [1,1,5]);
            
            y3 = obj.c3.pulse_shape(t);
            y4 = obj.c4.pulse_shape(t);
            y_ref = zeros(10,1,5);
            y_ref(:,:,1) = y3;
            y_ref(:,:,2) = y4;
            y_ref(:,:,3) = y4;
            y_ref(:,:,4) = y3;
            y_ref(:,:,5) = y3;
            
            [yout, tout] = func_eval_ind(obj.c_lookup1, 2, ind, @pulse_shape, t);
            assertEqual (size(tout), [10,1,5])
            assertEqual (size(yout), [10,1,5])
            assertEqual (t_ref, tout)
            assertEqual (y_ref, yout)
        end
        
        %======================================================================
        function [ok, mess] = check_size_and_type (obj)
            % Utility method that checks that the size and class of properties
            % are correct.
            ok = false;     % assume the worst
            if ~iscolumn(obj.object_store)
                mess = 'object_store must be a column vector';
                return
            end
            if ~iscolumn(obj.indx) || ~iscell(obj.indx) || ...
                    ~all(cellfun(@isnumeric,obj.indx)) ||...
                    ~all(cellfun(@iscolumn,obj.indx))
                mess = 'indx must be a column cellarray of numeric column vectors';
                return
            end
            if ~isnumeric(obj.narray) || ~isscalar(obj.narray)
                mess = 'narray must be a numeric scalar';
                return
            end
            if ~isnumeric(obj.nelmts) || ~iscolumn(obj.nelmts)
                mess = 'nelmts must be a numeric column vector';
                return
            end
            if ~iscell(obj.sz) || ~iscolumn(obj.sz) || ...
                    ~all(cellfun(@isnumeric,obj.sz)) ||...
                    ~all(cellfun(@isroa,obj.sz))
                mess = 'sz must be a column cellarray of numeric row vectors';
                return
            end
            ok = true;
            mess = '';
            
        end
        
    end
end


%==========================================================================
function [ok, mess] = check_size_and_type (obj)
% Utility method that checks that the size and class of properties
% are correct.
ok = false;     % assume the worst
if ~iscolumn(obj.object_store)
    mess = 'object_store must be a column vector';
    return
end
if ~iscolumn(obj.indx) || ~iscell(obj.indx) || ...
        ~all(cellfun(@isnumeric,obj.indx)) ||...
        ~all(cellfun(@iscolumn,obj.indx))
    mess = 'indx must be a column cellarray of numeric column vectors';
    return
end
if ~isnumeric(obj.narray) || ~isscalar(obj.narray)
    mess = 'narray must be a numeric scalar';
    return
end
if ~isnumeric(obj.nelmts) || ~iscolumn(obj.nelmts)
    mess = 'nelmts must be a numeric column vector';
    return
end
if ~iscell(obj.sz) || ~iscolumn(obj.sz) || ...
        ~all(cellfun(@isnumeric,obj.sz)) ||...
        ~all(cellfun(@isrow,obj.sz))
    mess = 'sz must be a column cellarray of numeric row vectors';
    return
end
ok = true;
mess = '';

end

%==========================================================================
function t = time_array (fermi_chopper, sz)
% Return an array of times at which to evaluate the chopper transmission
%
%   >> t = time_array (fermi_chopper, sz)
%
% Use to test sizes of output arguments from func_eval_ind
% Constructed by using linspace over the range of transmission
% Note that if a scalar is required, it does NOT return t=0, but at
% half the tme at which transmission goes to zero. This is so that different
% chopper objects will return difference transmissions and can therefore
% be distinguished.

if numel(sz)==1
    sz = [sz,sz];
end
nel = prod(sz);
if ~isrow(sz) || ~all(rem(sz,1)==0) || any(sz<0) || ~all(isfinite(sz)) || nel<1
    error('HERBERT:test_object_lookup:invalid_argument','Check input arguments')
end

[tlo, thi] = fermi_chopper.pulse_range();
if nel>1
    t = reshape(linspace(tlo,thi,nel), sz);
else
    t = thi/2;
end

end
