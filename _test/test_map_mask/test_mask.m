classdef test_mask < TestCaseWithSave
    % test_mask  Tests IX_mask class
    
    methods
        %--------------------------------------------------------------------------
        % Test constructor
        %--------------------------------------------------------------------------
        function test_empty_constructor (~)
            % Test the empty constructor
            w = IX_mask();
            assertTrue (isempty(w.msk), 'Default mask constructor problem')
        end
        
        function test_constructor_bad (~)
            % Should fail because cannot have zero as a mask index
            func = @() IX_mask(0:9);
            assertExceptionThrown (func, 'IX_mask:set:invalid_argument');
        end
        
        function test_constructor_sort_remove_duplicates_1 (~)
            % Test constructor sorting and removing duplicates
            w = IX_mask ([34:54, 2:5, 30:40]);
            assertEqual (w.msk, [2:5, 30:54],...
                'Constructor not eliminating duplicates, or sorting')
        end
        
        function test_constructor_sort_remove_duplicates_2 (~)
            % Test constructor sorting and removing duplicates
            % More complex case
            w = IX_mask ([60:-1:50, 2:5, 30:40, 19:23]);
            assertEqual (w.msk, [2:5, 19:23, 30:40, 50:60],...
                'Constructor not eliminating duplicates, or sorting')
        end
        
        function test_constructor_sort_remove_duplicates_3 (~)
            % Test constructor sorting and removing duplicates
            % More complex case still
            w = IX_mask ([60:-1:50, 2:5, 30:40, 19:23, 38:42, 10:12]);
            assertEqual (w.msk, [2:5, 10:12, 19:23, 30:42, 50:60],...
                'Constructor not eliminating duplicates, or sorting')
        end
        
        %------------------------------------------------------------------
        % Test reading from ASCII file
        %------------------------------------------------------------------
        function test_construct_from_file_single_line (~)
            % Test reading a mask file
            w = IX_mask ('msk_1.msk');
            wref = IX_mask ([34:54, 2:5, 30:40]);
            assertEqual (w.msk, wref.msk,...
                'File and array constructors not equivalent')
        end
        
        function test_construct_from_file_multiple_lines (~)
            % Test reading a mask file
            w = IX_mask ('msk_2.msk');
            wref = IX_mask ([60:-1:50, 2:5, 30:40, 19:23]);
            assertEqual (w.msk, wref.msk,...
                'File and array constructors not equivalent')
        end
        
        function test_construct_from_file_multiple_lines_and_comments (~)
            % Test reading a mask file
            w = IX_mask ('msk_3.msk');
            wref = IX_mask ([2:5, 10:12, 19:23, 30:42, 50:62]);
            assertEqual (w.msk, wref.msk,...
                'File and array constructors not equivalent')
        end
        
        %------------------------------------------------------------------
        % Test writing then reading ASCII file gives identity
        %------------------------------------------------------------------
        function test_IO_ascii_0 (~)
            % Empty mask ASCII IO
            w = IX_mask();
            tmpfile = fullfile(tmp_dir,'tmp.msk');
            cleanup = onCleanup(@()delete(tmpfile));
            save(w, tmpfile)
            wtmp = IX_mask.read(tmpfile);
            assertTrue (isequal(w,wtmp), 'Write+read does not make an identity');
        end
        
        function test_IO_ascii_1 (~)
            % Non-empty mask ASCII IO
            w = IX_mask ([34:54, 2:5, 30:40]);
            tmpfile = fullfile(tmp_dir,'tmp.msk');
            cleanup = onCleanup(@()delete(tmpfile));
            save(w, tmpfile)
            wtmp = IX_mask.read(tmpfile);
            assertTrue (isequal(w,wtmp), 'Write+read does not make an identity');
        end
        
        function test_IO_ascii_2 (~)
            % Non-empty mask ASCII IO
            w = IX_mask ([60:-1:50, 2:5, 30:40, 19:23]);
            tmpfile = fullfile(tmp_dir,'tmp.msk');
            cleanup = onCleanup(@()delete(tmpfile));
            save(w, tmpfile)
            wtmp = IX_mask.read(tmpfile);
            assertTrue (isequal(w,wtmp), 'Write+read does not make an identity');
        end
        
        function test_IO_ascii_3 (~)
            % Non-empty mask ASCII IO
            w = IX_mask ([60:-1:50, 2:5, 30:40, 19:23, 38:42, 10:12]);
            tmpfile = fullfile(tmp_dir,'tmp.msk');
            cleanup = onCleanup(@()delete(tmpfile));
            save(w, tmpfile)
            wtmp = IX_mask.read(tmpfile);
            assertTrue (isequal(w,wtmp), 'Write+read does not make an identity');
        end
        
        %------------------------------------------------------------------
        % Test combine
        %------------------------------------------------------------------
        function test_combine_1 (~)
            % Test combine with one argument only
            w = IX_mask ('msk_1.msk');
            c = combine (w);
            assertEqual (w, c)
        end
        
        function test_combine_2 (~)
            % Test combining with an empty
            w = IX_mask ('msk_1.msk');
            c = combine (w, IX_mask());
            assertEqual (w, c)
        end
        
        function test_combine_3 (~)
            % Test combining two scalar masks
            w1 = IX_mask ('msk_1.msk');
            w2 = IX_mask ('msk_2.msk');
            c = combine (w1, w2);
            cref = IX_mask ([2:5,19:23,30:60]);
            assertEqual (cref, c)
        end
        
        function test_combine_4 (~)
            % Combine the masks in an array
            w1 = IX_mask ([2:5, 21:26, 31:35]);
            w2 = IX_mask ([4:8, 18:22, 25:33]);
            w = [w1, w2];
            c = combine (w);
            cref = IX_mask ([2:8, 18:35]);
            assertEqual (cref, c)
            assertEqual (cref.msk, [2:8, 18:35])
        end
        
        function test_combine_5 (~)
            % Combine the masks in several arrays
            w1(1) = IX_mask([2:5, 21:26, 31:35]);
            w1(2) = IX_mask([4:8, 18:22, 25:33]);
            w2(1) = IX_mask();
            w2(2) = IX_mask([30:40, 45:52]);
            w2(3) = IX_mask([60:65, 70:75]);
            w3(1) = IX_mask([68:-1:63, 43:48]);
            w3(2) = IX_mask(20:-1:15);
            c = combine (w1, w2, w3);
            cref = IX_mask ([2:8, 15:40, 43:52, 60:68, 70:75]);
            assertEqual (cref, c)
            assertEqual (cref.msk, [2:8, 15:40, 43:52, 60:68, 70:75])
        end
        
    end
end
