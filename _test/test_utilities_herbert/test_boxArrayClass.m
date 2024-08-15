classdef test_boxArrayClass < TestCase
    % Test boxArrayClass, a class created to test object_lookup methods
    % rand_ind and func_eval_ind for objects with inner arrays
    %
    % Forms a pair with boxArrayClass defined elsewhere
    
    properties
        boxArray
        position
        sides
        x1col_ref
        x1row_ref
        x12_ref
    end
    
    methods
        %--------------------------------------------------------------------------
        function obj = test_boxArrayClass (name)
            obj = obj@TestCase(name);
            
            % Create boxArray with four different boxes
            position = [[11;21;31], [111;121;131], [1011;1021;1031], [700;30;100]];
            sides = [[1;2;3], [10;50;100], [110;121;3], [0.8;12;4]];
            obj.boxArray = boxArrayClass(position, sides);
            obj.position = position;
            obj.sides = sides;
            
            % Points in the boxes
            rand1col = 0.485 * rand(3,4);   % random position as fraction of side
            rand1row = 0.485 * rand(3,4);   % random position as fraction of side
            rand12 = cat (2, 0.485 * rand(3,1,4), 0.235 * rand(3,1,4));
            
            x1col = position + rand1col.*sides;
            x1row = reshape(position + rand1row.*sides, [1,3,4]);
            ptmp = reshape(position,[3,1,4]);
            stmp = reshape(sides,[3,1,4]);
            x12 = cat(2,ptmp,ptmp) + rand12.*cat(2,stmp,stmp);

            obj.x1col_ref = x1col;
            obj.x1row_ref = x1row;
            obj.x12_ref = x12;
            
        end
        
        %--------------------------------------------------------------------------
        % Test constructor
        %--------------------------------------------------------------------------
        function test_boxArrayClass_constructor_no_arguments (~)
            % Test constructor with no arguments
            box_tmp = boxArrayClass();
            box_array = boxClass();
            assertEqual (box_tmp.box, box_array)
            assertEqual (box_tmp.nbox, 1)
        end
        
        function test_boxArrayClass_constructor_one_box (~)
            % Test constructor with one box
            box_tmp = boxArrayClass ([5,1000,10000], [1,40,200]);
            box_array = boxClass ([5,1000,10000], [1,40,200]);
            assertEqual (box_tmp.box, box_array)
        end
        
        function test_boxArrayClass_constructor_array_of_boxes (~)
            % Test constructor of array of boxes
            pos1 = [101,102,103];
            sides1 = [11,22,33];
            pos2 = [5,1000,10000];
            sides2 = [1,40,200];
            box_tmp = boxArrayClass ([pos1(:),pos2(:)], [sides1(:),sides2(:)]);
            box_array = boxClass ([pos1(:),pos2(:)], [sides1(:),sides2(:)]);
            assertEqual (box_tmp.box, box_array)
        end
        
        function test_boxArrayClass_constructor_expand_sides_arg (~)
            % Test constructor with expansion of single side argument to match
            % number of position arguments
            pos1 = [101,102,103];
            sides1 = [11,22,33];
            pos2 = [5,1000,10000];
            box_tmp = boxArrayClass ([pos1(:),pos2(:)], sides1);
            box_array = boxClass ([pos1(:),pos2(:)], [sides1(:),sides1(:)]);
            assertEqual (box_tmp.box, box_array)
        end
        
        function test_boxArrayClass_constructor_invalid_element_count (~)
            % Test failure with invalid input:
            pos1 = [101,102,103];
            sides1 = [11,22,33,44];     % too many elements (should only be 3)
            pos2 = [5,1000,10000];
            
            f = @()boxArrayClass ([pos1(:),pos2(:)], sides1(:));
            assertExceptionThrown(f,'HERBERT:boxArrayClass:invalid_argument');
        end
        
        %--------------------------------------------------------------------------
        % Test sizes of arrays produced by rand_elmts_position output
        %--------------------------------------------------------------------------
        function test_output_size_rowVectorStacking (obj)
            % Test size of output arrays when stacked [1,10]
            ielmts = [1,3,1,3,3,3,2,2,1,2];
            [x1col, x1row, x12] = rand_elmts_position (obj.boxArray, ielmts);
            assertEqual (size(x1col), [3,10])
            assertEqual (size(x1row), [1,3,10])
            assertEqual (size(x12), [3,2,10])
        end
        
        function test_output_size_columnVectorStacking (obj)
            % Test size of output arrays when stacked [10,1]
            ielmts = [1;3;1;3;3;3;2;2;1;2];
            [x1col, x1row, x12] = rand_elmts_position (obj.boxArray, ielmts);
            assertEqual (size(x1col), [3,10])
            assertEqual (size(x1row), [1,3,10])
            assertEqual (size(x12), [3,2,10])
        end
        
        function test_output_size_arrayStacking (obj)
            % Test size of output arrays when stacked [2,5]
            ielmts = [1,3,1,3,3;3,2,2,1,2];
            [x1col, x1row, x12] = rand_elmts_position (obj.boxArray, ielmts);
            assertEqual (size(x1col), [3,2,5])
            assertEqual (size(x1row), [1,3,2,5])
            assertEqual (size(x12), [3,2,2,5])
        end
        
        %--------------------------------------------------------------------------
        % Test validate_points_in boxArray
        %--------------------------------------------------------------------------
        function test_validate_points_in_boxArray (obj)
            % Test points are really in boxes as designed
            for i=1:obj.boxArray.nbox
                [ok, mess] = validate_points_in_boxArray (obj.boxArray, i, ...
                    obj.x1col_ref(:,i), obj.x1row_ref(1,:,i), obj.x12_ref(:,:,i));
                assertTrue (ok, mess)
            end
        end
        
        function test_validate_points_in_boxArray_THROW (obj)
            % Make a point outside the range - validate_points_in_boxArray
            % should fail
            i = 3;
            x1col_bad = obj.x12_ref(:,:,i);
            x1col_bad(4) = 1e6;
            ok = validate_points_in_boxArray (obj.boxArray, i, ...
                obj.x1col_ref(:,i), obj.x1row_ref(1,:,i), x1col_bad);
            assertFalse (ok, ['ERROR: validate_points_in_boxArray should have failed',...
                ' due to x12 being out of range'])
        end
        
        function test_validate_points_in_boxArray_shifted (obj)
            % Test points in box with shifts bigger than box sides
            shift1c = [1000; 1200; 1400];
            shift1r = [1100; 1120; 1140];
            shift12 = [-2100; -9200; -6200];
            
            i = 3;
            [ok, mess] = validate_points_in_boxArray (obj.boxArray, i, ...
                obj.x1col_ref(:,i) + shift1c, obj.x1row_ref(1,:,i) + shift1r', ...
                obj.x12_ref(:,:,i) + repmat(shift12,[1,2]), ...
                shift1c, shift1r, shift12);
            assertTrue (ok, mess)
        end
        
        function test_validate_points_in_boxArray_shifted_outOfRange (obj)
            % Test failure if do not test with shifted x1col, x1row, x12
            shift1c = [1000; 1200; 1400];
            shift1r = [1100; 1120; 1140];
            shift12 = [-2100; -9200; -6200];
            
            i = 3;
            ok = validate_points_in_boxArray (obj.boxArray, i, ...
                obj.x1col_ref(:,i), obj.x1row_ref(1,:,i), obj.x12_ref(:,:,i), ...
                shift1c, shift1r, shift12);
            assertFalse (ok, ['ERROR: validate_points_in_boxArray should have failed',...
                ' due to points being out of range'])
        end
        
        function test_validate_points_in_boxArray_ielmts (obj)
            % Test multiple points in box without shift
            ielmts = [4,2,3,1,4,2,4,2,3,2,3,3,3,1];
            x1col = obj.x1col_ref(:,ielmts);
            x1row = obj.x1row_ref(:,:,ielmts);
            x12 = obj.x12_ref(:,:,ielmts);
            
            [ok, mess] = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12);
            assertTrue (ok, mess)
        end
        
        function test_validate_points_in_boxArray_ielmts_oneShift (obj)
            % Test multiple points in box with single shift
            ielmts = [4,2,3,1,4,2,4; 2,3,2,3,3,3,1];
            sz = size(ielmts);
            nel = numel(ielmts);
            
            % Get points in unshifted boxes
            W = obj.sides;
            x1col = obj.x1col_ref(:,ielmts(:));
            x1col = x1col + 0.01*rand(size(x1col)).*W(:,ielmts(:));
            x1col = reshape (x1col, size_array_stack([3,1],sz));
            
            x1row = obj.x1row_ref(:,:,ielmts(:));
            x1row = x1row + 0.01*rand(size(x1row)).*reshape(W(:,ielmts(:)),size(x1row));
            x1row = reshape (x1row, size_array_stack([1,3],sz));

            x12 = obj.x12_ref(:,:,ielmts(:));
            WW = reshape (W(:,ielmts(:)), [3,1,nel]);
            x12 = x12 + 0.01*rand(size(x12)).*cat(2,WW,WW);
            x12 = reshape (x12, size_array_stack([3,2],sz));
            
            % Shifts
            shift1c = [1000; 1200; 1400];
            shift1r = [1100; 1120; 1140];
            shift12 = [-2100; -9200; -6200];
            
            % Check fails if pass shifts to validation, but don't shift
            % x1col, x1row and x12
            ok = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertFalse(ok, 'ERROR: validate_points_in_boxArray should have returned false')
            
            % Shift points
            x1col = x1col + shift1c;
            x1row = x1row + shift1r';
            x12 = x12 + repmat(shift12,[1,2]);

            [ok, mess] = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertTrue (ok, mess)
            
            % Put one point outside and check for failure
            x1row(round(numel(x1row)/2)) = 1e7;
            ok = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertFalse (ok, 'ERROR: validate_points_in_boxArray should have returned false')
        end
        
        function test_validate_points_in_boxArray_ielmts_multiShift (obj)
            % Test multiple points in box with multiple shifts
            ielmts = [4,2,3,1,4,2,4; 2,3,2,3,3,3,1];
            sz = size(ielmts);
            nel = numel(ielmts);
            
            % Get points in unshifted boxes
            W = obj.sides;
            x1col = obj.x1col_ref(:,ielmts(:));
            x1col = x1col + 0.01*rand(size(x1col)).*W(:,ielmts(:));
            x1col = reshape (x1col, size_array_stack([3,1],sz));
            
            x1row = obj.x1row_ref(:,:,ielmts(:));
            x1row = x1row + 0.01*rand(size(x1row)).*reshape(W(:,ielmts(:)),size(x1row));
            x1row = reshape (x1row, size_array_stack([1,3],sz));

            x12 = obj.x12_ref(:,:,ielmts(:));
            WW = reshape (W(:,ielmts(:)), [3,1,nel]);
            x12 = x12 + 0.01*rand(size(x12)).*cat(2,WW,WW);
            x12 = reshape (x12, size_array_stack([3,2],sz));
            
            % Shifts
            sz_shift = size_array_stack([3,1],sz);
            offsets = reshape (1:prod(sz_shift), sz_shift);
            shift1c = [1000; 1200; 1400] + 10*offsets;
            shift1r = [1100; 1120; 1140] + 100*offsets;
            shift12 = [-2100; -9200; -6200] + 1000*offsets;
            
            % Check fails if pass shifts to validation, but don't shift
            % x1col, x1row and x12
            ok = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertFalse(ok, 'ERROR: validate_points_in_boxArray should have returned false')
            
            % Shift points
            x1col = x1col + shift1c;
            x1row = x1row + reshape(shift1r, size(x1row));
            sz_tmp = size(x12); sz_tmp(2) = 1;
            shift12_tmp = reshape(shift12, sz_tmp);
            x12 = x12 + cat(2,shift12_tmp,shift12_tmp);

            [ok, mess] = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertTrue (ok, mess)
            
            % Put one point outside and check for failure
            x1col(round(numel(x1col)/2)) = 1e7;
            ok = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertFalse (ok, 'ERROR: validate_points_in_boxArray should have returned false')
        end
                
        %--------------------------------------------------------------------------
        % Test sizes of arrays produced by rand_elmts_position output
        % Assumes that validate_rand_elmts_position works correctly
        %--------------------------------------------------------------------------
        function test_rand_elmts_position_oneShift (obj)
            % Test rand_position, duplicating call to rand_pos with just
            % one shift vector
            shift1c = [10,12,14];
            shift1r = [110,112,114];
            shift12 = [-100,-90,-60];
            ielmts = [1,3,1,3,3;3,2,2,1,2];
            % Random sampling
            [x1col, x1row, x12] = rand_elmts_position (obj.boxArray, ielmts, ...
                shift1c, shift1r, shift12);
            % Validate
            [ok, mess] = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertTrue(ok, mess)
        end
        
        function test_rand_elmts_position_multiShift (obj)
            % Test rand_position, duplicating call to rand_pos with
            % different shift vector for each point
            
            % Create arrays of shifts, stacked size [2,5]
            shift1c = [10;12;14] + reshape([(0:-1000:-4000);(-5000:-1000:-9000)], [1,2,5]);
            shift1r = [110;112;114] + reshape([(0:-1000:-4000);(-5000:-1000:-9000)], [1,2,5]);
            shift12 = [-100;-90;-60] + reshape([(0:-1000:-4000);(-5000:-1000:-9000)], [1,2,5]);
            ielmts = [1,3,1,3,3;3,2,2,1,2];
            
            % Random sampling
            [x1col, x1row, x12] = rand_elmts_position (obj.boxArray, ielmts, ...
                shift1c, shift1r, shift12);
            
            % Validate
            [ok, mess] = validate_points_in_boxArray (obj.boxArray, ielmts, ...
                x1col, x1row, x12, shift1c, shift1r, shift12);
            assertTrue(ok, mess)
        end
        
        
        %--------------------------------------------------------------------------
        % Test sizes of arrays produced by rand_elmts_position output
        % Assumes that validate_rand_elmts_position works correctly
        %--------------------------------------------------------------------------
        function test_range_elmts_oneShift (obj)
            % Test range_elmts, duplicating call to range with just
            % one shift vector
            shift1c = [10,12,14];
            shift1r = [110,112,114];
            shift12 = [-100,-90,-60];
            ielmts = [1,3,1,3,3;3,2,2,1,2];
            
            % Ranges
            [r1col, r1row, r12] = range_elmts (obj.boxArray, ielmts, ...
                shift1c, shift1r, shift12);
            
            % Validate
            r1col_ref = NaN(3,2,10);
            r1row_ref = NaN(3,2,10);
            r12_ref = NaN(3,2,2,10);
            for i=1:numel(ielmts)
                [r1col_ref(:,:,i), r1row_ref(:,:,i), r12_ref(:,:,:,i)] = range ...
                    (obj.boxArray.box(ielmts(i)), shift1c, shift1r, shift12);
            end
            r1col_ref = reshape(r1col_ref, [3,2,2,5]);
            r1row_ref = reshape(r1row_ref, [3,2,2,5]);
            r12_ref = reshape(r12_ref, [3,2,2,2,5]);

            assertEqual (r1col_ref, r1col)
            assertEqual (r1row_ref, r1row)
            assertEqual (r12_ref, r12)
        end
        
        function test_range_elmts_multiShift (obj)
            % Test rand_position, duplicating call to rand_pos with
            % different shift vector for each point
            
            % Create arrays of shifts, stacked size [2,5]
            shift1c = [10;12;14] + reshape([(0:-1000:-4000);(-5000:-1000:-9000)], [1,2,5]);
            shift1r = [110;112;114] + reshape([(0:-1000:-4000);(-5000:-1000:-9000)], [1,2,5]);
            shift12 = [-100;-90;-60] + reshape([(0:-1000:-4000);(-5000:-1000:-9000)], [1,2,5]);
            ielmts = [1,3,1,3,3;3,2,2,1,2];
            
            % Ranges
            [r1col, r1row, r12] = range_elmts (obj.boxArray, ielmts, ...
                shift1c, shift1r, shift12);
            
            % Validate
            r1col_ref = NaN(3,2,10);
            r1row_ref = NaN(3,2,10);
            r12_ref = NaN(3,2,2,10);
            shift1c_tmp = reshape(shift1c, [3,10]);
            shift1r_tmp = reshape(shift1r, [3,10]);
            shift12_tmp = reshape(shift12, [3,10]);
            for i=1:numel(ielmts)
                [r1col_ref(:,:,i), r1row_ref(:,:,i), r12_ref(:,:,:,i)] = range ...
                    (obj.boxArray.box(ielmts(i)), ...
                    shift1c_tmp(:,i), shift1r_tmp(:,i), shift12_tmp(:,i));
            end
            r1col_ref = reshape(r1col_ref, [3,2,2,5]);
            r1row_ref = reshape(r1row_ref, [3,2,2,5]);
            r12_ref = reshape(r12_ref, [3,2,2,2,5]);

            assertEqual (r1col_ref, r1col)
            assertEqual (r1row_ref, r1row)
            assertEqual (r12_ref, r12)
        end
        
        
        %------------------------------------------------------------------
        % Test object_lookup with boxArrayClass
        %------------------------------------------------------------------
        function test_create_object_lookup_singleArray (~)
            % Create an object_lookup with a single array input
            b1 = boxArrayClass(rand(3,6), rand(3,6));
            b2 = boxArrayClass(rand(3,8), rand(3,8));
            b3 = boxArrayClass(rand(3,6), rand(3,6));

            barr=[b2,b3,b1,b2,b1,b3,b2];

            barr_u = object_lookup(barr);
            
            % Confirm only three distinct objects
            assertEqual (numel(barr_u.object_store), 3)
            
            % Confirm object_array(1) reproduces the input array
            assertEqual (barr_u.object_array(1), barr)
            
        end
                
        function test_create_object_lookup_arrayFetchERROR (~)
            % Create an object_lookup with a single array input
            b1 = boxArrayClass(rand(3,6), rand(3,6));
            b2 = boxArrayClass(rand(3,8), rand(3,8));
            b3 = boxArrayClass(rand(3,6), rand(3,6));

            barr=[b2,b3,b1,b2,b1,b3,b2];

            barr_u = object_lookup(barr);
            
            % Confirm object_array(2) results in an error
            f = @()barr_u.object_array(2);
            assertExceptionThrown (f, 'HERBERT:object_lookup:invalid_argument');
            
        end
                
        function test_create_object_lookup_arrayFetch (~)
            % Create an object_lookup with three array inputs
            b1 = boxArrayClass(rand(3,6), rand(3,6));
            b2 = boxArrayClass(rand(3,8), rand(3,8));
            b3 = boxArrayClass(rand(3,6), rand(3,6));
            b4 = boxArrayClass(rand(3,5), rand(3,5));

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
