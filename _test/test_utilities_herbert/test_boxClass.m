classdef test_boxClass < TestCase
    % Test boxClass, a class created to test object_lookup methods
    % rand_ind and func_eval_ind
    %
    % Forms a pair with boxClass defined elsewhere
    
    properties
        box
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_boxClass (name)
            obj = obj@TestCase(name);
            
            obj.box = boxClass ([5,1000,10000], [1,40,200]);
            
        end
        
        %--------------------------------------------------------------------------
        % Test constructor
        %--------------------------------------------------------------------------
        function test_boxClass_constructor_noArgs (~)
            % Test constructor with no arguments
            box_tmp = boxClass();
            assertEqual (box_tmp.position, [0;0;0])
            assertEqual (box_tmp.sides, [0;0;0])
        end
        
        function test_boxClass_constructor_oneBox (~)
            % Test constructor of one box
            box_tmp = boxClass ([5,1000,10000], [1,40,200]);
            assertEqual (box_tmp.position, [5;1000;10000])
            assertEqual (box_tmp.sides, [1;40;200])
        end
        
        function test_boxClass_constructor_multipleBoxes (~)
            % Test constructor of array of boxes
            pos1 = [101,102,103];
            sides1 = [11,22,33];
            pos2 = [5,1000,10000];
            sides2 = [1,40,200];
            box1_tmp = boxClass (pos1, sides1);
            box2_tmp = boxClass (pos2, sides2);
            box_tmp = boxClass ([pos1(:),pos2(:)], [sides1(:),sides2(:)]);
            assertEqual (box_tmp, [box1_tmp, box2_tmp])
        end
        
        function test_boxClass_constructor_multiplePosn_singleSide (~)
            % Test constructor of array of boxes with same side lengths
            pos1 = [101,102,103];
            sides1 = [11,22,33];
            pos2 = [5,1000,10000];
            box1_tmp = boxClass (pos1, sides1);
            box2_tmp = boxClass (pos2, sides1);
            box_tmp = boxClass ([pos1(:),pos2(:)], sides1(:));
            assertEqual (box_tmp, [box1_tmp, box2_tmp])
        end
        
        %--------------------------------------------------------------------------
        % Test sizes of arrays produced by rand_position
        %--------------------------------------------------------------------------
        function test_output_size_noShifts (obj)
            % Test size of output arrays when stacked [2,4]
            [x1col, x1row, x12] = rand_position (obj.box, [2,4]);
            assertEqual (size(x1col), [3,2,4])
            assertEqual (size(x1row), [1,3,2,4])
            assertEqual (size(x12), [3,2,2,4])
        end
        
        function test_outputSize_zeroShifts (obj)
            % Test size of output arrays when stacked [2,4]
            [x1col, x1row, x12] = rand_position (obj.box, [2,4], ...
                [0,0,0], [0,0,0], [0,0,0]);
            assertEqual (size(x1col), [3,2,4])
            assertEqual (size(x1row), [1,3,2,4])
            assertEqual (size(x12), [3,2,2,4])
        end
        
        function test_outputSize_stackedShift (obj)
            % Test size of output arrays when stacked [2,4]
            % Different branch is followed if one or more shifts are
            % stacks of vectors
            [x1col, x1row, x12] = rand_position (obj.box, [2,4], ...
                [0,0,0], rand(3,2,4), [0,0,0]);
            assertEqual (size(x1col), [3,2,4])
            assertEqual (size(x1row), [1,3,2,4])
            assertEqual (size(x12), [3,2,2,4])
        end
        
        function test_output_size_shift_arraySampling (obj)
            % Test with shift and size of output arrays when stacked [4,5]
            shift1c = [10,12,14];
            shift1r = [110,112,114];
            shift12 = [-100,-90,-60];
            sz = [4,5];
            [x1col, x1row, x12] = rand_position (obj.box, sz, shift1c, shift1r, shift12);
            assertEqual (size(x1col), [3,4,5])
            assertEqual (size(x1row), [1,3,4,5])
            assertEqual (size(x12), [3,2,4,5])
        end
        
        function test_outputSize_stackedShifts_arraySampling (obj)
            % Test with shift and size of output arrays when stacked [4,5]
            % Different branch is followed if one or more shifts are
            % stacks of vectors
            shift1c = rand(3,4,5);
            shift1r = rand(1,3,4,5);
            shift12 = rand(3,4,5);
            sz = [4,5];
            [x1col, x1row, x12] = rand_position (obj.box, sz, shift1c, shift1r, shift12);
            assertEqual (size(x1col), [3,4,5])
            assertEqual (size(x1row), [1,3,4,5])
            assertEqual (size(x12), [3,2,4,5])
        end
        
        function test_outputSize_shift_rowVectorSampling (obj)
            % Test with shift and size of output arrays when stacked [1,5]
            shift1c = [10,12,14];
            shift1r = [110,112,114];
            shift12 = [-100,-90,-60];
            sz = [1,5];
            [x1col, x1row, x12] = rand_position (obj.box, sz, shift1c, shift1r, shift12);
            assertEqual (size(x1col), [3,5])
            assertEqual (size(x1row), [1,3,5])
            assertEqual (size(x12), [3,2,5])
        end
        
        function test_outputSize_stackedShift_rowVectorSampling (obj)
            % Test with shift and size of output arrays when stacked [1,5]
            % Different branch is followed if one or more shifts are
            % stacks of vectors
            shift1c = rand(3,5);
            shift1r = rand(1,3,5);
            shift12 = rand(1,3,5);
            sz = [1,5];
            [x1col, x1row, x12] = rand_position (obj.box, sz, shift1c, shift1r, shift12);
            assertEqual (size(x1col), [3,5])
            assertEqual (size(x1row), [1,3,5])
            assertEqual (size(x12), [3,2,5])
        end
        
        %--------------------------------------------------------------------------
        % Test range calculation
        %--------------------------------------------------------------------------
        function test_range_1 (obj)
            % Test range for unshifted box
            [r1col, r1row, r12] = range (obj.box);
            assertEqual (r1col, [4.5,5.5; 980,1020; 9900,10100])
            assertEqual (r1row, [4.5,5.5; 980,1020; 9900,10100])
            lower = [4.5, 4.75; 980, 990; 9900, 9950];
            upper = [5.5, 5.25; 1020, 1010; 10100, 10050];
            assertEqual (r12, cat(3,lower,upper))
        end
        
        function test_range_2 (obj)
            % Test range for shifted box
            shift1c = [10,12,14];
            shift1r = [110,112,114];
            shift12 = [-100,-90,-60];
            r1col_ref = [4.5,5.5; 980,1020; 9900,10100] + repmat(shift1c(:),[1,2]);
            r1row_ref = [4.5,5.5; 980,1020; 9900,10100] + repmat(shift1r(:),[1,2]);
            lower = [4.5, 4.75; 980, 990; 9900, 9950];
            upper = [5.5, 5.25; 1020, 1010; 10100, 10050];
            r12_ref = cat(3,lower,upper) + repmat(shift12(:),[1,2,2]);
            
            [r1col, r1row, r12] = range (obj.box, shift1c, shift1r, shift12);
            assertEqual (r1col, r1col_ref)
            assertEqual (r1row, r1row_ref)
            assertEqual (r12, r12_ref)
        end
        
        function test_range_3 (obj)
            % Test range for shifted box
            % Different branch is followed if one or more shifts are
            % stacks of vectors
            sz_stack = [5,7];
            shift1c = rand(3,5,7);
            shift1r = rand(3,5,7);
            shift12 = rand(3,5,7);
            [r1col, r1row, r12] = range (obj.box, sz_stack, shift1c, shift1r, shift12);
            
            % Get reference values
            r1col_ref = NaN([3,2,5,7]);
            r1row_ref = NaN([3,2,5,7]);
            r12_ref = NaN([3,2,2,5,7]);
            
            assertEqual (size(r1col), size(r1col_ref))
            assertEqual (size(r1row), size(r1row_ref))
            assertEqual (size(r12), size(r12_ref))

            for i=1:5
                for j=1:7
                [r1col_ref(:,:,i,j), r1row_ref(:,:,i,j), r12_ref(:,:,:,i,j)] = range ...
                    (obj.box, shift1c(:,i,j), shift1r(:,i,j), shift12(:,i,j));
                end
            end

            assertEqual (r1col, r1col_ref)
            assertEqual (r1row, r1row_ref)
            assertEqual (r12, r12_ref)
        end
        
        %--------------------------------------------------------------------------
        % Test validate_points_in_box (assumes method range has been tested
        % as validate_points_in_box depends on it)
        %--------------------------------------------------------------------------
        function test_validate_points_in_box_1a (obj)
            % Test validation for a single point, no shift
            
            % Points in the box
            x1col = [5.3; 981; 10100];
            x1row = [4.5, 1020, 9999];
            x12 = [5.3, 981, 10100; 5.15, 990, 10050]';
            
            % Validate
            sz = [1,1];
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12);
            assertTrue(ok, mess)
        end
        
        function test_validate_points_in_box_1b (obj)
            % Test validation for a single point, no shift
            % Should fail as x1row out of range
            
            % x1col, x12 in the box; x1row outside
            x1col = [5.3; 981; 10100];
            x1row = [4.5, 1021, 9999];
            x12 = [5.3, 981, 10100; 5.15, 990, 10050]';
            
            % Validate
            sz = [1,1];
            ok = validate_points_in_box (obj.box, sz, x1col, x1row, x12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
        end
        
        function test_validate_points_in_box_2a (obj)
            % Test validation for a single point, with shift
            shift1c = [10; 12; 14];
            shift1r = [110; 112; 114];
            shift12 = [-100; -90; -60];
            
            % Points in unshifted box
            x1col = [5.3; 981; 10100];
            x1row = [4.5, 1020, 9999];
            x12 = [5.3, 981, 10100; 5.15, 990, 10050]';
            
            % Shift points:
            x1col = x1col + shift1c;
            x1row = x1row + shift1r';
            x12 = x12 + repmat(shift12,[1,2]);
            
            % Validate
            sz = [1,1];
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue(ok, mess)
        end
        
        function test_validate_points_in_box_2b (obj)
            % Test validation for a single point, with shift
            % Should fail as x1row out of range
            shift1c = [10; 12; 14];
            shift1r = [110; 112; 114];
            shift12 = [-100; -90; -60];
            
            % x1col, x12 in the box; x1row outside
            x1col = [5.3; 981; 10100];
            x1row = [4.5, 1021, 9999];
            x12 = [5.3, 981, 10100; 5.15, 990, 10050]';
            
            % Shift points:
            x1col = x1col + shift1c;
            x1row = x1row + shift1r';
            x12 = x12 + repmat(shift12,[1,2]);
            
            % Validate
            sz = [1,1];
            ok = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')

        end

        function test_validate_points_in_box_3 (obj)
            % Test validation for a multiple points, with single shift
            
            % Points in unshifted box
            sz = [5,3];
            x1col = [5.3; 981; 10099] + 0.01*rand(size_array_stack([3,1],sz));
            x1row = [4.5, 1019, 9999] + 0.01*rand(size_array_stack([1,3],sz));
            x12 = [5.3, 981, 10099; 5.15, 990, 10049]' + ...
                0.01*rand(size_array_stack([3,2],sz));
            
            % Shifts
            shift1c = [10; 12; 14];
            shift1r = [110; 112; 114];
            shift12 = [-100; -90; -60];
            
            % Check fails if pass shifts to validation, but don't shift
            % x1col, x1row and x12
            ok = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
            
            % Shift points, and check that now passes validation
            x1col = x1col + shift1c;
            x1row = x1row + shift1r';
            x12 = x12 + repmat(shift12,[1,2]);
            
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue(ok, mess)
            
            % Put one point outside; test for failure
            ind = numel(x12)/2;
            dx = 10*max(abs(shift12(:)));
            x12(ind) = x12(ind) + dx;  % some large value way out of the box
            ok = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
        end
        
        function test_validate_points_in_box_4 (obj)
            % Test validation for a multiple points, with different shifts
            % per point
            % Points in unshifted box
            sz = [5,3];
            x1col = [5.3; 981; 10099] + 0.01*rand(size_array_stack([3,1],sz));
            x1row = [4.5, 1019, 9999] + 0.01*rand(size_array_stack([1,3],sz));
            x12 = [5.3, 981, 10099; 5.15, 990, 10049]' + ...
                0.01*rand(size_array_stack([3,2],sz));
            
            % Shifts
            sz_shift = size_array_stack([3,1],sz);
            offsets = reshape (1:prod(sz_shift), sz_shift);
            shift1c = [10; 12; 14] + 10*offsets;
            shift1r = [110; 112; 114] + 100*offsets;
            shift12 = [-100; -90; -60] + 1000*offsets;
            
            % Check fails if pass shifts to validation, but don't shift
            % x1col, x1row and x12
            ok = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
            
            % Shift points, and check that now passes validation
            x1col = x1col + shift1c;
            x1row = x1row + reshape(shift1r, size(x1row));
            sz_tmp = size(x12); sz_tmp(2) = 1;
            shift12_tmp = reshape(shift12, sz_tmp);
            x12 = x12 + cat(2,shift12_tmp,shift12_tmp);
            
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue(ok, mess)
            
            % Put one point outside; test for failure
            ind = numel(x12)/2;
            dx = 10*max(abs(shift12(:)));
            x12(ind) = x12(ind) + dx;  % some large value way out of the box
            ok = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
        end
        
        function test_validate_points_in_box_5a (obj)
            % Test validation for a multiple points, with single shift
            % Testing size: column vector
            
            % Points in unshifted box
            sz = [1,6];
            x1col = [5.3; 981; 10099] + 0.01*rand(size_array_stack([3,1],sz));
            x1row = [4.5, 1019, 9999] + 0.01*rand(size_array_stack([1,3],sz));
            x12 = [5.3, 981, 10099; 5.15, 990, 10049]' + ...
                0.01*rand(size_array_stack([3,2],sz));

            % Validate
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12);
            assertTrue(ok, mess)

            % Confirm failure if give incorrect expected size
            sz_false = [1,5];
            ok = validate_points_in_box (obj.box, sz_false, x1col, x1row, x12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
        end
        
        function test_validate_points_in_box_5b (obj)
            % Test validation for a multiple points, with single shift
            % Testing size: 2D array
            
            % Points in unshifted box
            sz = [4,6];
            x1col = [5.3; 981; 10099] + 0.01*rand(size_array_stack([3,1],sz));
            x1row = [4.5, 1019, 9999] + 0.01*rand(size_array_stack([1,3],sz));
            x12 = [5.3, 981, 10099; 5.15, 990, 10049]' + ...
                0.01*rand(size_array_stack([3,2],sz));

            % Validate
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12);
            assertTrue(ok, mess)

            % Confirm failure if give incorrect expected size
            sz_false = [2,12];  % same number of elements, different shape
            ok = validate_points_in_box (obj.box, sz_false, x1col, x1row, x12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
        end
        
        function test_validate_points_in_box_5c (obj)
            % Test validation for a multiple points, with single shift
            % Testing size: weird array
            
            % Points in unshifted box
            sz = [1,1,4,6];
            x1col = [5.3; 981; 10099] + 0.01*rand(size_array_stack([3,1],sz));
            x1row = [4.5, 1019, 9999] + 0.01*rand(size_array_stack([1,3],sz));
            x12 = [5.3, 981, 10099; 5.15, 990, 10049]' + ...
                0.01*rand(size_array_stack([3,2],sz));

            % Validate
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12);
            assertTrue(ok, mess)

            % Confirm failure if give incorrect expected size
            sz_false = [1,4,6];
            ok = validate_points_in_box (obj.box, sz_false, x1col, x1row, x12);
            assertFalse(ok, 'ERROR: validate_points_in_box should have failed')
        end
        
        %--------------------------------------------------------------------------
        % Test rand_position output; assumes we have tested validate_points_in_box
        %--------------------------------------------------------------------------
        function test_rand_position_1 (obj)
            % Test rand_position with no shift vectors
            sz = [1000,10];
            
            % Random sampling
            [x1col, x1row, x12] = rand_position (obj.box, sz);
            
            % Validate
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12);
            assertTrue(ok, mess)
        end
        
        function test_rand_position_2 (obj)
            % Test rand_position with just one shift vector
            shift1c = [10,12,14];
            shift1r = [110,112,114];
            shift12 = [-100,-90,-60];
            sz = [1000,10];
            
            % Random sampling
            [x1col, x1row, x12] = rand_position (obj.box, sz, shift1c, shift1r, shift12);
            
            % Validate
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue(ok, mess)
        end
        
        function test_rand_position_3 (obj)
            % Test rand_position with stack of shift vectors
            sz = [1000,10];
            sz_shift = size_array_stack([3,1],sz);
            offsets = reshape (1:prod(sz_shift), sz_shift);
            shift1c = [10; 12; 14] + 10*offsets;
            shift1r = [110; 112; 114] + 100*offsets;
            shift12 = [-100; -90; -60] + 1000*offsets;
            
            % Random sampling
            [x1col, x1row, x12] = rand_position (obj.box, sz, shift1c, shift1r, shift12);
            
            % Validate
            [ok, mess] = validate_points_in_box (obj.box, sz, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue(ok, mess)
        end
        
        function test_rand_position_4 (obj)
            % Test rand_position with shift vectors stacked by the array
            % size of the random sampling. Test by validating that all
            % random points generated for the array of shifts lie in the
            % box ranges. Restrict to randomly selection from just two
            % shifts to make hand-crafted test feasible
            %
            % A test left over from earlier incaration of this class, but
            % keep as an extra safety-net test.
            shift1c_1 = [10,12,14];
            shift1r_1 = [110,112,114];
            shift12_1 = [-100,-90,-60];
            shift1c_2 = [110,212,314];
            shift1r_2 = [4110,5112,6114];
            shift12_2 = [-7100,-890,-960];
            sz = [5,7]; % not communsurate with length of a shift vector
            ind = [2,1,2,1,1,2,1,1,2,1,1,1,2,2,1,2 2 1 2 2 2 1 2 2 2 2 1 2 1 2 2 2 2 1 2];
            s1col_2D = zeros(3,35);
            s1col_2D(:,ind==1) = repmat(shift1c_1(:), [1,sum(ind==1)]);
            s1col_2D(:,ind==2) = repmat(shift1c_2(:), [1,sum(ind==2)]);
            s1col = reshape(s1col_2D, [3,5,7]);
            s1row_2D = zeros(3,35);
            s1row_2D(:,ind==1) = repmat(shift1r_1(:)', [1,1,sum(ind==1)]);
            s1row_2D(:,ind==2) = repmat(shift1r_2(:)', [1,1,sum(ind==2)]);
            s1row = reshape(s1row_2D, [1,3,5,7]);
            s12_2D = zeros(3,35);
            s12_2D(:,ind==1) = repmat(shift12_1(:)', [1,1,sum(ind==1)]);
            s12_2D(:,ind==2) = repmat(shift12_2(:)', [1,1,sum(ind==2)]);  
            s12 = reshape(s12_2D, [1,3,5,7]);
            
            % Random sampling
            [x1col, x1row, x12] = rand_position (obj.box, sz, s1col, s1row, s12);
            
            % Validate array sizes
            assertEqual (size(x1col), [3,5,7]);
            assertEqual (size(x1row), [1,3,5,7]);
            assertEqual (size(x12), [3,2,5,7]);
            
            % Validate random points are in range
            x1col_2D = reshape (x1col, [3,35]);
            x1row_2D = reshape (x1row, [3,35]);
            x12_3D = reshape (x12, [3,2,35]);
            for i=1:prod(sz)
                if ind(i)==1
                    [ok, mess] = validate_points_in_box (obj.box, [1,1], ...
                        x1col_2D(:,i), x1row_2D(:,i)', x12_3D(:,:,i), ...
                        shift1c_1, shift1r_1, shift12_1);
                else
                    [ok, mess] = validate_points_in_box (obj.box, [1,1], ...
                        x1col_2D(:,i), x1row_2D(:,i)', x12_3D(:,:,i), ...
                        shift1c_2, shift1r_2, shift12_2);
                end
                assertTrue(ok, mess)
            end
        end
        
        %------------------------------------------------------------------
        % Test object_lookup with boxClass
        %------------------------------------------------------------------
        function test_create_object_lookup_1 (~)
            % Create an object_lookup with a single array input
            b1=boxClass([0,0,0],[0,0,0]);
            b2=boxClass([-18,0,0],[10,20,30]);
            b3=boxClass([0,120,0],[50,100,2000]);

            barr=[b2,b3,b1,b2,b1,b3,b2];

            barr_u = object_lookup(barr);
            
            % Confirm only three distinct objects
            assertEqual (numel(barr_u.object_store), 3)
            
            % Confirm object_array(1) reproduces the input array
            assertEqual (barr_u.object_array(1), barr)
            
        end
                
        function test_create_object_lookup_2 (~)
            % Create an object_lookup with a single array input
            b1=boxClass([0,0,0],[0,0,0]);
            b2=boxClass([-18,0,0],[10,20,30]);
            b3=boxClass([0,120,0],[50,100,2000]);

            barr=[b2,b3,b1,b2,b1,b3,b2];

            barr_u = object_lookup(barr);
            
            % Confirm object_array(2) results in an error
            f = @()barr_u.object_array(2);
            assertExceptionThrown (f, 'HERBERT:object_lookup:invalid_argument');
            
        end
                
        function test_create_object_lookup_3 (~)
            % Create an object_lookup with three array inputs
            b1=boxClass([0,0,0],[0,0,0]);
            b2=boxClass([-18,0,0],[10,20,30]);
            b3=boxClass([0,120,0],[50,100,2000]);
            b4=boxClass([0,90,0],[20,15,12]);

            barr1=[b2,b3,b1,b2,b1,b3,b2];
            barr2=[b3,b2,b2,b4];
            barr3=[b1,b4,b4,b1,b4];

            barr_u = object_lookup({barr1, barr2, barr3});
            
            % Confirm only four distinct objects
            assertEqual (numel(barr_u.object_store), 4)
            
            % Confirm object_array reproduces the input arrays
            assertEqual (barr_u.object_array(1), barr1)
            assertEqual (barr_u.object_array(2), barr2)
            assertEqual (barr_u.object_array(3), barr3)
            
        end
                
        %------------------------------------------------------------------
    end
end
