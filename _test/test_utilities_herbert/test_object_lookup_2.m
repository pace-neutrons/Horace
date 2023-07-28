classdef test_object_lookup_2 < TestCase
    % Class that tests object_lookup methods rand_ind and func_eval_ind
    %
    % Uses the boxClass and boxArrayClass classes defined elsewhere as
    % exemplar classes on which to test the functionality.
    
    properties
        % boxClass objects, arrays and lookup
        b1
        b2
        b3
        b4
        
        ind1
        ind2
        ind3
        
        barr1
        barr2
        barr3
        
        barrCell
        
        blook
        
        % boxArrayClass objects, arrays and lookup
        b
        
        indA1
        indA2
        indA3
        
        bAarr1
        bAarr2
        bAarr3
        
        bAarrCell
        
        bAlook
    end
    
    methods
        %------------------------------------------------------------------
        function obj = test_object_lookup_2 (name)
            obj = obj@TestCase(name);
            
            % Four boxes with extents much less than unity along each side
            % and which have no overlap.
            % An arbitrary array of boxes drawn from these boxes can be
            % shifted by, for example, succesively 1,2,3,4,... along the
            % y-axis and still remain without overlap regardless of
            % whatever the components of the shifts are along the x and z
            % axes. This enables tests which have unique shifts for each
            % box.
            
            % Make three boxClass arrays from four boxes
            % ------------------------------------------
            b1 = boxClass ([3,0,3000], 1e-3*[5,6,7]);
            b2 = boxClass ([2,0,2000], 1e-3*[10,11,12]);
            b3 = boxClass ([4,0,4000], 1e-3*[15,16,17]);
            b4 = boxClass ([1,0,1000], 1e-3*[20,21,22]);
            
            barr = [b1, b2, b3, b4];
            
            % Arrays of boxes
            ind1 = [2,3,1,2,1,3,2];
            ind2 = [3,1,2,2,4,1];
            ind3 = [1,4,4,1,4];
            barr1 = barr(ind1);
            barr2 = barr(ind2);
            barr3 = barr(ind3);
            
            barrCell = {barr1, barr2, barr3};
            
            % Make object lookup of boxClass arrays
            blook = object_lookup(barrCell);
            
            
            % Make three boxArrayClass arrays from four boxArray objects
            % ----------------------------------------------------------
            nbox = 10;
            b = repmat(boxClass, [1,nbox]);
            xc = [3,2,4,1,9,5,8,6,7,10];
            for i=1:10
                pos = [xc(i),0,1000*xc(i)];
                sides = 1e-2*(0.1 + rand(1,3));
                b(i) = boxClass(pos,sides);
            end

            bA1 = boxArray_from_boxes (b([1,5,4,2]));
            bA2 = boxArray_from_boxes (b([3,9,9,10,9]));
            bA3 = boxArray_from_boxes (b([7,7,3,2,8,8,3,8]));
            bA4 = boxArray_from_boxes (b([2,2,3,6]));
            
            
            bAarr = [bA1, bA2, bA3, bA4];
            
            % Arrays of boxes
            indA1 = [2,3,1,2,1,3,2];
            indA2 = [2,1,4,2,3,1];
            indA3 = [1,4,4,1,4];
            bAarr1 = bAarr(indA1);
            bAarr2 = bAarr(indA2);
            bAarr3 = bAarr(indA3);
            
            bAarrCell = {bAarr1, bAarr2, bAarr3};
            
            % Make object lookup of boxClass arrays
            bAlook = object_lookup(bAarrCell);            
            
            
            % Fill properties for the tests
            % -----------------------------
            obj.b1 = b1;
            obj.b2 = b2;
            obj.b3 = b3;
            obj.b4 = b4;
            
            obj.ind1 = ind1;
            obj.ind2 = ind2;
            obj.ind3 = ind3;
            
            obj.barr1 = barr1;
            obj.barr2 = barr2;
            obj.barr3 = barr3;
            
            obj.barrCell = barrCell;
            
            obj.blook = blook;
            
            obj.b = b;
            
            obj.indA1 = indA1;
            obj.indA2 = indA2;
            obj.indA3 = indA3;
            
            obj.bAarr1 = bAarr1;
            obj.bAarr2 = bAarr2;
            obj.bAarr3 = bAarr3;
            
            obj.bAarrCell = bAarrCell;
            
            obj.bAlook = bAlook;
        end
        
        %------------------------------------------------------------------
        % Test rand_ind
        %------------------------------------------------------------------
        % Single point
        %------------------------------------------------------------------
        function test_rand_ind_1 (obj)
            % Test single random point: array 2, index 5: this is box 4
            iarray = 2;
            ind = 5;
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Validate:
            [ok, mess] = validate_points_in_box (obj.b4, [1,1], x1col, x1row, x12);
            assertTrue (ok, mess);
            
            % Now validate_boxClass_rand_ind (a validation of that function)
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, ...
                x1col, x1row, x12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_2 (obj)
            % Test single random point: array 2, index 5: this is box 4
            % Force a failure - a test of boxClass/validate_points_in_box
            iarray = 2;
            ind = 5;
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Validate: test against box2, rather than the (correct) box 4.
            % This should result in a failure
            ok = validate_points_in_box (obj.b2, [1,1], x1col, x1row, x12);
            assertFalse (ok, 'ERROR: validate_points_in_box should have failed')
            
            % Validate: test it fails against box 2 which has no overlap
            %(box 2 is array 2, index 3)
            ind_fail = 3;
            ok = validate_boxClass_rand_ind (obj.barr2, ind_fail, x1col, x1row, x12);
            assertFalse (ok, 'ERROR: validate_boxClass_rand_ind should have failed')
        end
        
        %------------------------------------------------------------------
        % Single box, multiple points (output array shape tests)
        %------------------------------------------------------------------
        function test_rand_ind_3a (obj)
            % Test array of random points from a single box:
            % array 2, index 5: this is box 4
            iarray = 2;
            sz = [1,5];
            ind = 5 * ones(sz);
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Validate:
            [ok, mess] = validate_points_in_box (obj.b4, sz, x1col, x1row, x12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_3b (obj)
            % Test array of random points from a single box:
            % array 2, index 5: this is box 4
            iarray = 2;
            sz = [5,1];
            ind = 5 * ones(sz);
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Validate:
            [ok, mess] = validate_points_in_box (obj.b4, sz, x1col, x1row, x12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_3c (obj)
            % Test array of random points from a single box:
            % array 2, index 5: this is box 4
            iarray = 2;
            sz = [1,1,5];
            ind = 5 * ones(sz);
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Validate:
            [ok, mess] = validate_points_in_box (obj.b4, sz, x1col, x1row, x12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_3d (obj)
            % Test array of random points from a single box:
            % array 2, index 5: this is box 4
            iarray = 2;
            sz = [1,7,5];
            ind = 5 * ones(sz);
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Validate:
            [ok, mess] = validate_points_in_box (obj.b4, sz, x1col, x1row, x12);
            assertTrue (ok, mess);
        end
        
        %------------------------------------------------------------------
        % Multiple boxes, multiple points (output array shape tests)
        %------------------------------------------------------------------
        function test_rand_ind_4a (obj)
            % Test array of random points from two distinct boxes:
            % array 2, index 5: this is box 4
            % array 2, index 3: this is box 2
            % Handcraft the validation - it acts as a buttress to the
            % validity of the function validate_boxClass_rand_ind defined
            % in this test class file
            iarray = 2;
            ind = [5,3,3,5,3; 3,5,5,5,3];     % has size [2,5]
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Handcrafted validation
            assertEqual (size(x1col), [3,2,5]);
            assertEqual (size(x1row), [1,3,2,5]);
            assertEqual (size(x12), [3,2,2,5]);
            x1col_2D = reshape(x1col,[3,10]);
            x1row_2D = reshape(x1row,[3,10]);
            x12_3D = reshape(x12,[3,2,10]);
            for i=[2,3,5,9,10]  % indices==3, correspond to box 2
                [ok, mess] = validate_points_in_box (obj.b2, [1,1], ...
                    x1col_2D(:,i), x1row_2D(:,i)', x12_3D(:,:,i));
                assertTrue (ok, mess)
            end
            for i=[1,4,6,7,8]  % indices==5, correspond to box 4
                [ok, mess] = validate_points_in_box (obj.b4, [1,1], ...
                    x1col_2D(:,i), x1row_2D(:,i)', x12_3D(:,:,i));
                assertTrue (ok, mess)
            end
            
            % Validate using validate_boxClass_rand_ind - a check
            % that it also gives the same result
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, ...
                x1col, x1row, x12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_4b (obj)
            % Test array of random points from three distinct boxes:
            % array 2, index 5: this is box 4
            % array 2, index 2 and 6: this is box 1
            iarray = 2;
            ind = [5,2,2,6,5; 2,5,6,2,5; 2,5,6,5,6];
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position);
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, ...
                x1col, x1row, x12);
            assertTrue (ok, mess);
            
            % Test it fails if one point out of range
            x1row(round(numel(x1row)/2)) = 1e7;
            ok = validate_boxClass_rand_ind (obj.barr2, ind, ...
                x1col, x1row, x12);
            assertFalse (ok, 'ERROR: validate_boxClass_rand_ind should have failed');
        end
        
        %------------------------------------------------------------------
        % Single box, single point, with shifts
        %------------------------------------------------------------------
        function test_rand_ind_5 (obj)
            % Test single random point: array 2, index 5: this is box 4
            % Should fail as only one shift given, not three (can give
            % none, or all three)
            iarray = 2;
            ind = 5;
            shift1c = [5,50,500];
            f = @()rand_ind (obj.blook, iarray, ind, @rand_position, shift1c);
            assertExceptionThrown (f, 'HERBERT:boxClass:invalid_argument');
        end
        
        function test_rand_ind_6 (obj)
            % Test single random point: array 2, index 5: this is box 4
            iarray = 2;
            ind = 5;
            shift1c = [5,50,500];
            shift1r = [-5,-50,-500];
            shift12 = [0,5,100];
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position, ...
                shift1c, shift1r, shift12);
            
            % Validation failure as shifts not passed:
            ok = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12);
            assertFalse (ok, '');
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        %------------------------------------------------------------------
        % Single box, multiple points, with shifts
        %------------------------------------------------------------------
        function test_rand_ind_7 (obj)
            % Test single box, multiple points, single shift
            % iarray = 2, ind = 5 is box 4
            iarray = 2;
            sz = [1,5];
            ind = 5 * ones(sz);
            shift1c = [5,50,500];
            shift1r = [-5,-50,-500];
            shift12 = [0,5,100];
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position, ...
                shift1c, shift1r, shift12);
            
            % Validation failure as shifts not passed:
            ok = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12);
            assertFalse (ok, '');
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_8 (obj)
            % Test single box, multiple points, multiple shifts
            % array 2, index 5: this is box 4
            iarray = 2;
            sz = [1,7,5];
            ind = 5 * ones(sz);
            yshift_only = false;
            [shift1c, shift1r, shift12] = shifts_boxes_no_overlaps (sz, yshift_only);
            
            % Incorrect use of rand_ind: should cause a failure
            % Need to use the 'split' option as the arguments shift1c, shift1r, shift12
            % to rand_position are stacked arrays, not arguments to be used
            % in their entirelty for every point indicated by ind.
            f = @()rand_ind (obj.blook, iarray, ind, @rand_position, ...
                shift1c, shift1r, shift12);
            assertExceptionThrown (f, 'HERBERT:boxClass:invalid_argument');
            
            % Correct use of rand_ind
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, 'split', @rand_position, ...
                shift1c, shift1r, shift12);
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_9 (obj)
            % Test single box, multiple points, multiple shifts
            % One of the shifts will be a single vector, so is an argument
            % to be used in its entirety  for every point
            % array 2, index 5: this is box 4
            iarray = 2;
            sz = [1,7,5];
            ind = 5 * ones(sz);
            yshift_only = false;
            [shift1c, ~, shift12] = shifts_boxes_no_overlaps (sz, yshift_only);
            shift1r = [3,0,23];
            
            % Incorrect use of rand_ind: should cause a failure
            % Need to use the 'split' option for both shift1c and shift12
            f = @()rand_ind (obj.blook, iarray, ind, ...
                'split', 1, @rand_position, shift1c, shift1r, shift12);
            assertExceptionThrown (f, 'HERBERT:boxClass:invalid_argument');
            
            % Correct use of rand_ind
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, ...
                'split', [1,3], @rand_position, shift1c, shift1r, shift12);
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        %------------------------------------------------------------------
        % Multiple boxes, multiple points, with shifts
        %------------------------------------------------------------------
        function test_rand_ind_10 (obj)
            % Test single box, multiple points, single shift
            % iarray 2, index 5: this is box 4
            % iarray 2, index 3: this is box 2
            iarray = 2;
            ind = [5,3,3,5,3; 3,5,5,5,3];     % has size [2,5]
            shift1c = [5,50,500];
            shift1r = [-5,-50,-500];
            shift12 = [0,5,100];
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, @rand_position, ...
                shift1c, shift1r, shift12);
            
            assertEqual (size(x1col), size_array_stack([3,1],size(ind)))
            assertEqual (size(x1row), size_array_stack([1,3],size(ind)))
            assertEqual (size(x12), size_array_stack([3,2],size(ind)))
            
            % Validation failure as shifts not passed:
            ok = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12);
            assertFalse (ok, '');
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_11 (obj)
            % Test single box, multiple points, multiple shifts
            % iarray 2, index 5: this is box 4
            % iarray 2, index 3: this is box 2
            iarray = 2;
            ind = [...
                5     5     5     5     3     5     3 ...
                3     3     5     5     5     3     5 ...
                5     3     3     5     5     3     3 ...
                3     5     3     5     5     3     5 ...
                5     5     5     3     3     3     3];
            yshift_only = false;
            [shift1c, shift1r, shift12] = shifts_boxes_no_overlaps (size(ind), yshift_only);
            
            % Incorrect use of rand_ind: should cause a failure
            % Need to use the 'split' option as the arguments shift1c, shift1r, shift12
            % to rand_position are stacked arrays, not arguments to be used
            % in their entirelty for every point indicated by ind.
            f = @()rand_ind (obj.blook, iarray, ind, @rand_position, ...
                shift1c, shift1r, shift12);
            assertExceptionThrown (f, 'HERBERT:boxClass:invalid_argument');
            
            % Correct use of rand_ind
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, 'split', @rand_position, ...
                shift1c, shift1r, shift12);
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        function test_rand_ind_12 (obj)
            % Test single box, multiple points, multiple shifts
            % One of the shifts will be a single vector, so is an argument
            % to be used in its entirety  for every point
            % iarray 2, index 5: this is box 4
            % iarray 2, index 3: this is box 2
            iarray = 2;
            ind = [...
                5     5     5     5     3     5     3 ...
                3     3     5     5     5     3     5 ...
                5     3     3     5     5     3     3 ...
                3     5     3     5     5     3     5 ...
                5     5     5     3     3     3     3];
            yshift_only = false;
            [shift1c, ~, shift12] = shifts_boxes_no_overlaps (size(ind), yshift_only);
            shift1r = [3,0,23];
            
            % Incorrect use of rand_ind: should cause a failure
            % Need to use the 'split' option for both shift1c and shift12
            f = @()rand_ind (obj.blook, iarray, ind, ...
                'split', 1, @rand_position, shift1c, shift1r, shift12);
            assertExceptionThrown (f, 'HERBERT:boxClass:invalid_argument');
            
            % Correct use of rand_ind
            [x1col, x1row, x12] = rand_ind (obj.blook, iarray, ind, ...
                'split', [1,3], @rand_position, shift1c, shift1r, shift12);
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (obj.barr2, ind, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        %------------------------------------------------------------------
        % Test rand_ind on objects with an inner ordering i.e. call with
        % ielmts too.
        %------------------------------------------------------------------
        % Single boxArray, multiple boxes, multiple points, with shifts
        %------------------------------------------------------------------
        function test_rand_ind_13 (obj)
            % Test single boxArray, two boxes, multiple points, single shift
            % iarray 2, index 5: this is boxArray 3
            % then ielmts 4 & 6 are boxes 2 & 8
            iarray = 2;
            ind = 5*ones(2,5);
            ielmts = [6,6,4,6,4; 4,4,6,4,4];
            shift1c = [5,50,500];
            shift1r = [-5,-50,-500];
            shift12 = [0,5,100];
            [x1col, x1row, x12] = rand_ind (obj.bAlook, iarray, ind, ielmts, ...
                @rand_elmts_position, shift1c, shift1r, shift12);
            
            assertEqual (size(x1col), size_array_stack([3,1],size(ind)))
            assertEqual (size(x1row), size_array_stack([1,3],size(ind)))
            assertEqual (size(x12), size_array_stack([3,2],size(ind)))
            
            % To validate random points are in the correct boxes, construct
            % an array of boxClass objects such that ielmts indexes to the
            % correct boxes
            boxClass_array = repmat(boxClass, [1,6]);
            boxClass_array(4) = obj.b(2);
            boxClass_array(6) = obj.b(8);
            
            % Validation failure as shifts not passed:
            ok = validate_boxClass_rand_ind (boxClass_array, ielmts, x1col, x1row, x12);
            assertFalse (ok, '');
            
            % Validate:
            [ok, mess] = validate_boxClass_rand_ind (boxClass_array, ielmts, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        %------------------------------------------------------------------
        % Multiple boxArray objects, multiple points, with shifts
        %------------------------------------------------------------------
        function test_rand_ind_14 (obj)
            % Test two boxArray, two boxes, multiple points, single shift
            % iarray 2, index 5: this is boxArray 3
            %    - ielmts 4 & 6 are boxes 2 & 8
            % iarray 2, index 3: this is boxArray 4
            %    - ielmts 1 & 2 are box 2, ielmt 4 is box 6
            % With these values for iarray, ind and ielmts we get
            % a horrible mix of indices across the boxArrays, which
            % rand_ind has to cope with. Makes this a good test.

            iarray = 2;
            ind = [5,3,3,5,3; 5,5,5,3,3];
            ielmts = [4,4,1,6,2; 4,4,6,2,4];
            yshift_only = false;
            [shift1c, ~, shift12] = shifts_boxes_no_overlaps (size(ind), yshift_only);
            shift1r = [3,0,23];
            
            % Incorrect use of rand_ind: should cause a failure
            % Need to use the 'split' option for both shift1c and shift12
            f = @()rand_ind (obj.bAlook, iarray, ind, ielmts, ...
                'split', 1, @rand_elmts_position, shift1c, shift1r, shift12);
            assertExceptionThrown (f, 'HERBERT:boxArrayClass:invalid_argument');
            
            % Correct use of rand_ind
            [x1col, x1row, x12] = rand_ind (obj.bAlook, iarray, ind, ielmts, ...
                'split', [1,3], @rand_elmts_position, shift1c, shift1r, shift12);
            
            % To validate random points are in the correct boxes, construct
            % an array of boxClass objects such that ind and ielmts together 
            % index to the correct boxes.
            % Wasteful but readable construction
            boxClass_array = repmat(boxClass, [5,6]);  % size [numel(ind), numel(ielmts)]
            boxClass_array(5,4) = obj.b(2);
            boxClass_array(5,6) = obj.b(8);
            boxClass_array(3,[1,2]) = obj.b(2);
            boxClass_array(3,4) = obj.b(6);
            indtmp = sub2ind ([5,6], ind, ielmts);
            
            [ok, mess] = validate_boxClass_rand_ind (boxClass_array, indtmp, x1col, x1row, x12, ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess);
        end
        
        %------------------------------------------------------------------
        % Test func_eval_ind
        %------------------------------------------------------------------
        function test_func_eval_ind_1 (obj)
            % Single function evaluation
            % array 2, index 5: this is box 4
            iarray = 2;
            ind = 5;
            shift1c = [5,50,500];
            shift1r = [-5,-50,-500];
            shift12 = [0,5,100];
            [r1col, r1row, r12] = func_eval_ind (obj.blook, iarray, ind, @range, ...
                shift1c, shift1r, shift12);
            
            % Validate:
            [r1col_ref, r1row_ref, r12_ref] = range (obj.b4, shift1c, shift1r, shift12);
            assertEqual (r1col, r1col_ref);
            assertEqual (r1row, r1row_ref);
            assertEqual (r12, r12_ref);
        end
        
        function test_func_eval_ind_2 (obj)
            % Multiple function evaluations but on single box; single shift
            % array 2, index 5: this is box 4
            iarray = 2;
            ind = 5*ones(2,5);
            shift1c = [5,50,500];
            shift1r = [-5,-50,-500];
            shift12 = [0,5,100];
            [r1col, r1row, r12] = func_eval_ind (obj.blook, iarray, ind, @range, ...
                shift1c, shift1r, shift12);

            % Check sizes of return arguments
            assertEqual (size(r1col), [3,2,2,5]);
            assertEqual (size(r1row), [3,2,2,5]);
            assertEqual (size(r12), [3,2,2,2,5]);
            
            % Validate:
            [r1col_ref, r1row_ref, r12_ref] = range (obj.b4, size(ind), ...
                shift1c, shift1r, shift12);
            assertEqual (r1col, r1col_ref);
            assertEqual (r1row, r1row_ref);
            assertEqual (r12, r12_ref);
        end
        
        function test_func_eval_ind_3 (obj)
            % Multiple function evaluations across multiple boxes; single shift
            % array 2, index 5: this is box 4
            % array 2, index 3: this is box 2
            % Handcraft the validation - it acts as a buttress to the
            % validity of the function validate_boxClass_rand_ind defined
            % in this test class file
            iarray = 2;
            ind = [5,3,3,5,3; 3,5,5,5,3];     % has size [2,5]
            shift1c = [5,50,500];
            shift1r = [-5,-50,-500];
            shift12 = [0,5,100];
            [r1col, r1row, r12] = func_eval_ind (obj.blook, iarray, ind, @range, ...
                shift1c, shift1r, shift12);

            % Check sizes of return arguments
            assertEqual (size(r1col), [3,2,2,5]);
            assertEqual (size(r1row), [3,2,2,5]);
            assertEqual (size(r12), [3,2,2,2,5]);
            
            % Validate:
            % Handcraft the output
            r1col_ref = NaN (3,2,10);
            r1row_ref = NaN (3,2,10);
            r12_ref = NaN (3,2,2,10);
            [r1col_4, r1row_4, r12_4] = range (obj.b4, shift1c, shift1r, shift12); % box 4
            [r1col_2, r1row_2, r12_2] = range (obj.b2, shift1c, shift1r, shift12); % box 2
            for i=[1,4,6,7,8]  % indices==5, correspond to box 4
                r1col_ref(:,:,i) = r1col_4;
                r1row_ref(:,:,i) = r1row_4;
                r12_ref(:,:,:,i) = r12_4;
            end
            for i=[2,3,5,9,10]  % indices==3, correspond to box 2
                r1col_ref(:,:,i) = r1col_2;
                r1row_ref(:,:,i) = r1row_2;
                r12_ref(:,:,:,i) = r12_2;
            end
            r1col_ref = reshape (r1col_ref, [3,2,2,5]);
            r1row_ref = reshape (r1row_ref, [3,2,2,5]);
            r12_ref = reshape (r12_ref, [3,2,2,2,5]);
            assertEqual (r1col, r1col_ref);
            assertEqual (r1row, r1row_ref);
            assertEqual (r12, r12_ref);
        end
                
    end
end

%--------------------------------------------------------------------------
function [ok, mess] = validate_boxClass_rand_ind (obj, ind, x1col, x1row, x12, ...
    shift1col, shift1row, shift12)
% Validate rand_ind output against an array of boxClass objects.
% This array will normally be the one that was held in the object_lookup
% as indexed by input argument iarray to the call of rand_ind.
%
% If no shifts:
%   >> [ok, mess] = validate_boxClass_rand_ind (obj, ind, x1col, x1row, x12)
%
% If shifts:
%   >> [ok, mess] = validate_boxClass_rand_ind (obj, ind, x1col, x1row, x12, ...
%                                               shift1col, shift1row, shift12)

% Use the boXArrayClass validator to streamline the code in this function

% Construct boxArrayClass from the input array of boxClass objects
nbox = numel(obj);
pos = NaN(3,nbox);
sides = NaN(3,nbox);
for i=1:nbox
    pos(:,i) = obj(i).position;
    sides(:,i) = obj(i).sides;
end
boxArray = boxArrayClass (pos, sides);

% Now validate:
if nargin==5
    [ok, mess] = validate_points_in_boxArray (boxArray, ind, x1col, x1row, x12);
else
    [ok, mess] = validate_points_in_boxArray (boxArray, ind, ...
        x1col, x1row, x12, shift1col, shift1row, shift12);
end

end

%--------------------------------------------------------------------------
function [shift1c, shift1r, shift12] = shifts_boxes_no_overlaps (sz, yshift_only)
% Generate a set of shifts that ensure that none of the shifted boxes
% will overlap if they are shifted by these vectors. The output arrays are
% stacks of 3-vectors, stacked according to the size of the boxClass_array.

nbox = prod(sz);
iy = (1:nbox);
if yshift_only
    tmp = zeros(1,nbox);
    shift1c = [tmp; iy; tmp];
    shift1r = [tmp; iy; tmp];
    shift12 = [tmp; iy; tmp];
else
    shift1c = [sin(iy); iy; cos(iy)] ;
    shift1r = [iy.^1.2; iy; iy.^1.5] ;
    shift12 = [(iy.^1.6).*sin(iy); iy; (iy.^0.8).*cos(iy)] ;
end
shift1c = reshape(shift1c, size_array_stack([3,1], sz));
shift1r = reshape(shift1r, size_array_stack([3,1], sz));
shift12 = reshape(shift12, size_array_stack([3,1], sz));
end

%--------------------------------------------------------------------------
function boxArray_object = boxArray_from_boxes (boxClass_array)
% Utility function
nbox = numel(boxClass_array);
pos = NaN(3,nbox);
sides = NaN(3,nbox);
for i=1:nbox
    pos(:,i) = boxClass_array(i).position;
    sides(:,i) = boxClass_array(i).sides;
end
boxArray_object = boxArrayClass (pos, sides);
end
