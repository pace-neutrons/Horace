classdef test_map < TestCase
    % test_mask  Tests IX_mask class
    
    methods
        %--------------------------------------------------------------------------
        % Test constructor without repeat blocks
        %--------------------------------------------------------------------------
        function test_0Spec_1Work (~)
            % Zero spectra in one workspace. Works as scalar wkno means all
            % spectra mapped into one workspace
            map = IX_map([], 'wkno', 99);
            assertEqual(map.wkno, 99);
            assertEqual(map.ns, 0)
            assertEqual(map.s, zeros(1,0));
        end
        
        function test_0Spec_1Work_nsGiven (~)
            % Single spectrum to default single workspace
            map = IX_map([], 'wkno', 99, 'ns', 0);
            assertEqual(map.wkno, 99);
            assertEqual(map.ns, 0)
            assertEqual(map.s, zeros(1,0));
        end
        
        function test_0Spec_1Work_nsOnly (~)
            map = IX_map([],'ns',0);
            assertEqual(map.wkno, 1);  % default is workspace 1
            assertEqual(map.ns, 0)
            assertEqual(map.s, zeros(1,0));
        end
        
        function test_1Spec_1WorkDefault (~)
            % Single spectrum to default single workspace
            s = 17;
            map = IX_map(s);
            assertEqual(map.wkno, 1);  % default is workspace 1
            assertEqual(map.ns, 1)
            assertEqual(map.s, 17);
        end
        
        function test_1Spec_1Work (~)
            % Single spectrum to single workspace
            s = 17;
            map = IX_map(s, 'wkno', 5);
            assertEqual(map.wkno, 5);
            assertEqual(map.ns, 1)
            assertEqual(map.s, 17);
        end
        
        function test_manySpec_1Work (~)
            % Many spectra to single workspace
            s = [14;19;17];
            wkno = 5;
            map = IX_map(s, 'wkno', wkno);
            assertEqual(map.wkno, 5);
            assertEqual(map.ns, 3)
            assertEqual(map.s, [14,17,19]);     % sorted as all in one workspace
        end
        
        function test_manySpec_manyWorkDefault (~)
            % Many spectra to default 1:1 mapping
            s = [14;19;17];
            map = IX_map(s);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [1,1,1])
            assertEqual(map.s, [14,19,17]);
        end
        
        function test_manySpec_manyWork (~)
            % Many spectra to 1:1 workspace mapping
            s = [14;19;17];
            wkno = [6,4,9];
            map = IX_map(s, 'wkno', wkno);
            assertEqual(map.wkno, [4,6,9]);     % sorted
            assertEqual(map.ns, [1,1,1])
            assertEqual(map.s, [19,14,17]);     % sorted by workspace number
        end
        
        function test_manySpec_manyWork_many2one (~)
            % Many spectra to workspaces mapping; not 1:1
            s = [14;19;17;15;4];
            wkno = [6,4,9,4,6];
            map = IX_map(s, 'wkno', wkno);
            assertEqual(map.wkno, [4,6,9]);
            assertEqual(map.ns, [2,2,1])
            assertEqual(map.s, [15,19,4,14,17]);    % sorted by workspace number
            assertEqual(map.w, [4,4,6,6,9]);        % sorted
        end
        
        function test_negativeSpec_ERROR (~)
            % A negative spectrum number
            s = [14;-19;17];
            wkno = [6,4,9];
            f = @()IX_map(s, 'wkno', wkno);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ...
                'Spectrum numbers must all be greater than or equal to 1'))
        end
        
        function test_negativeWork_ERROR (~)
            % A negative workspace number
            s = [14;19;17];
            wkno = [6,-4,9];
            f = @()IX_map(s, 'wkno', wkno);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ...
                'Workspace numbers must all be greater than or equal to 1'))
        end
        
        function test_SpecAndWorkArrayMismatch_ERROR (~)
            % A negative workspace number
            s = [14;19;17];
            wkno = [6,9];
            f = @()IX_map(s, 'wkno', wkno);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ['The workspace array ',...
                    'must be scalar or have same length as spectrum array']))
        end
        
        function test_manySpec_manyWork_ns (~)
            % Many spectra to workspaces mapping; not 1:1
            s = [14;19;17;15;4];
            wkno = [6,4,9];
            map = IX_map(s, 'wkno', wkno, 'ns', [2,2,1]);
            assertEqual(map.wkno, [4,6,9]);
            assertEqual(map.ns, [2,2,1])
            assertEqual(map.s, [15,17,14,19,4]);    % sorted by workspace number
            assertEqual(map.w, [4,4,6,6,9]);        % sorted
        end
        
        function test_manySpec_manyWorkSomeEmpty_ns (~)
            % Many spectra to workspaces mapping; not 1:1
            s = [14;21;19;17;15;4];
            wkno = [2,6,4,8,9];
            map = IX_map(s, 'wkno', wkno, 'ns', [0,3,2,0,1]);
            assertEqual(map.wkno, [2,4,6,8,9]);
            assertEqual(map.ns, [0,2,3,0,1])
            assertEqual(map.s, [15,17,14,19,21,4]); % sorted by workspace number
            assertEqual(map.w, [4,4,6,6,6,9]);      % sorted
        end
        
        function test_manySpec_manyWorkSomeEmpty_nsWrongLength_ERROR (~)
            % sum(ns) matches numel(s), but numel(ns)~=numel(wkno) ==> error
            s = [14;21;19;17;15;4];
            wkno = [2,6,4,8,9];
            f = @()IX_map(s, 'wkno', wkno, 'ns', [0,3,2,1]);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ...
                'The number of elements in the array ''ns'', which gives the number of'))
        end
        
        function test_manySpec_manyWork_nsOnly (~)
            % Many spectra to workspaces mapping; not 1:1
            s = [14;19;17;15;4];
            map = IX_map(s, 'ns', [2,2,1]);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [2,2,1])
            assertEqual(map.s, [14,19,15,17,4]);    % sorted by workspace number
            assertEqual(map.w, [1,1,2,2,3]);        % sorted
        end
        
        function test_manySpec_manyWorkSomeEmpty_nsOnly (~)
            % Many spectra to workspaces mapping; not 1:1
            s = [14;21;19;17;15;4];
            map = IX_map(s, 'ns', [0,3,2,0,1]);
            assertEqual(map.wkno, [1,2,3,4,5]);
            assertEqual(map.ns, [0,3,2,0,1])
            assertEqual(map.s, [14,19,21,15,17,4]); % sorted by workspace number
            assertEqual(map.w, [2,2,2,3,3,5]);      % sorted
        end
                
        function test_manySpec_manyWork_nsOnly_ERROR (~)
            % sum(ns) does not match the number of spectra ==> error
            s = [14;19;17;15;4];
            f = @()IX_map(s, 'ns', [2,2,2]);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ['The number of spectra does not ' ...
                    'match the number expected in the workspaces']))
        end
        
        function test_WorkNumberIs0_ERROR (~)
            % This should fail as workspaces must have index number greater than
            % zero
            s = [15, 19, 4, 14, 17];
            wkno = [4, 6, 9, 0, 0, 0];
            ns = [2, 2, 1, 0, 0, 0];         
            f = @()IX_map(s, 'wkno', wkno, 'ns', ns);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ...
                'Workspace numbers must all be greater than or equal to 1'))
        end
        
        
        %--------------------------------------------------------------------------
        % Test constructor with contiguous ranges
        %--------------------------------------------------------------------------
        function test_range_1spec_1work (~)
            map = IX_map(1, 1, 1);
            assertEqual(map.wkno, 1);
            assertEqual(map.ns, 1)
            assertEqual(map.s, 1); % sorted by workspace number
        end
        
        function test_range_10spec_3work (~)
            map = IX_map(11, 20, 4);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [4,4,2])
            assertEqual(map.s, 11:20); % sorted by workspace number
        end
        
        function test_range_10spec_3workNegDelta (~)
            % Workspace numbers should decrease.
            map = IX_map(11, 20, -4);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [2,4,4]);
            assertEqual(map.s, [19,20,15,16,17,18,11,12,13,14])
        end
        
        function test_range_10spec_3workNegDelta_explicitFirst (~)
            % Workspace numbers should decrease.
            map = IX_map(11, 20, -4, 'wkno', 3);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [2,4,4]);
            assertEqual(map.s, [19,20,15,16,17,18,11,12,13,14])
        end
        
        function test_range_10specNegDelta_3work (~)
            % Workspace numbers should decrease.
            map = IX_map(20, 11, 4);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [4,4,2]);
            assertEqual(map.s, [17,18,19,20,13,14,15,16,11,12])
        end
        
        function test_range_10specNegDelta_3workNegDelta (~)
            % Workspace numbers should decrease.
            map = IX_map(20, 11, -4);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [2,4,4]);
            assertEqual(map.s, 11:20)
        end
        
        function test_range_10specNegDelta_3workNegDelta_explicitFirst (~)
            % Workspace numbers should decrease.
            map = IX_map(20, 11, -4, 'wkno', 3);
            assertEqual(map.wkno, [1,2,3]);
            assertEqual(map.ns, [2,4,4]);
            assertEqual(map.s, 11:20)
        end
        
        
        %--------------------------------------------------------------------------
        % Test constructor with repeat blocks
        %--------------------------------------------------------------------------
        function test_1Spec_1WorkDefault_3Repeat (~)
            % Single spectrum to default single workspace
            s = 17;
            nrepeat = 3;
            delta_s = 10;
            delta_w = 1;
            map = IX_map(s, 'repeat', [nrepeat, delta_s, delta_w]);
            assertEqual(map.wkno, [1, 2, 3]);  % default is workspace 1
            assertEqual(map.ns, [1, 1, 1])
            assertEqual(map.s, [17, 27, 37]);
        end
        
        function test_manySpec_manyWork_3Repeat (~)
            % Several spectra, one empty workspace, 3 repeats
            s = [21,22,31,32,33];
            wkno = [5,7,9];
            ns = [2,3,0];
            nrepeat = 3;
            delta_s = 20;
            delta_w = 100;
            map = IX_map(s, 'wkno', wkno, 'ns', ns, 'repeat', [nrepeat, delta_s, delta_w]);
            assertEqual(map.wkno, [5,7,9,105,107,109,205,207,209]);
            assertEqual(map.ns, [2 3 0 2 3 0 2 3 0])
            assertEqual(map.s, [21,22,31,32,33,41,42,51,52,53,61,62,71,72,73]);
        end
        
        function test_1Spec_1Work_3Repeat_negSpec_ERROR (~)
            % Single spectrum to single workspace
            s = 17;
            wkno = 5;
            nrepeat = 3;
            delta_s = -10;
            delta_w = 1;
            f = @()IX_map(s, 'wkno', wkno, 'repeat', [nrepeat, delta_s, delta_w]);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ['Spectrum array constructed for ',...
                'at least one repeated array includes zero or negative spectrum numbers']))
        end
        
        
        %------------------------------------------------------------------
        % Test read_ascii
        %------------------------------------------------------------------
        function test_read_0work (~)
            % Test reading a map file with explicitly 0 workspaces
            w = IX_map.read_ascii ('map_0work.map');
            assertEqual(w.wkno, zeros(1,0));
            assertEqual(w.ns, zeros(1,0))
            assertEqual(w.s, zeros(1,0));
        end
        
        function test_read_1work_0spec (~)
            % Test reading a map file with one workspace, no spectra
            w = IX_map.read_ascii ('map_1work_0spec.map');
            assertEqual(w.wkno, 99);
            assertEqual(w.ns, 0)
            assertEqual(w.s, zeros(1,0));
        end
        
        function test_read_1work_1spec (~)
            % Test reading a map file with one workspace, one spectrum
            w = IX_map.read_ascii ('map_1work_1spec.map');
            assertEqual(w.wkno, 99);
            assertEqual(w.ns, 1)
            assertEqual(w.s, 5);
        end
        
        function test_read_1work_5spec (~)
            % Test reading a map file with one workspace, five spectra
            w = IX_map.read_ascii ('map_1work_5spec.map');
            assertEqual(w.wkno, 99);
            assertEqual(w.ns, 5)
            assertEqual(w.s, [2,3,4,11,13]);
        end
        
        function test_read_1work_5spec_excessInfo_ERROR (~)
            % Test reading a map file with data for two workspaces, but only
            % declares one workspace
            f = @()IX_map.read_ascii ('map_1work_5spec_extraWorkspaceInfo.map');
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_file_format');
            assertTrue(contains(ME.message, ...
                'Unexpected data encountered after the full map file has been read'))
        end
        
        function test_read_2work_5and12spec (~)
            % Test reading a map file with two workspaces, five and 12 spectra
            w = IX_map.read_ascii ('map_2work_5and12spec.map');
            assertEqual(w.wkno, [23,99]);
            assertEqual(w.ns, [12,5])
            assertEqual(w.s, [1,3,5,7,16,19,22,23,24,25,36,40,2,3,4,11,13]);
        end
        
        function test_read_5work_noneEmpty (~)
            % Test reading a map file with five workspaces, none empty
            % It has nopn-standard extension (*.txt, not *.map)
            w = IX_map.read_ascii ('map_5work_noneEmpty.txt');
            assertEqual(w.wkno, [2,3,4,5,6]);
            assertEqual(w.ns, [5,6,7,8,9])
            assertEqual(w.s, [21:25, 31:36, 41:47, 51:58, 61:69]);
        end
        
        function test_read_5work_1stEmpty (~)
            % Test reading a map file with five workspaces, first one empty
            % Should simply be ignored and output has four workspaces
            w = IX_map.read_ascii ('map_5work_1stEmpty.map');
            assertEqual(w.wkno, [2,3,4,5,6]);
            assertEqual(w.ns, [0,6,7,8,9])
            assertEqual(w.s, [31:36, 41:47, 51:58, 61:69]);
        end
        
        function test_read_5work_3rdEmpty (~)
            % Test reading a map file with five workspaces, third empty
            % Should simply be ignored and output has four workspaces
            w = IX_map.read_ascii ('map_5work_3rdEmpty.map');
            assertEqual(w.wkno, [2,3,4,5,6]);
            assertEqual(w.ns, [5,6,0,8,9])
            assertEqual(w.s, [21:25, 31:36, 51:58, 61:69]);
        end
        
        function test_read_5work_5thEmpty (~)
            % Test reading a map file with five workspaces, last empty
            % Should simply be ignored and output has four workspaces
            w = IX_map.read_ascii ('map_5work_5thEmpty.map');
            assertEqual(w.wkno, [2,3,4,5,6]);
            assertEqual(w.ns, [5,6,7,8,0])
            assertEqual(w.s, [21:25, 31:36, 41:47, 51:58]);
        end
        
        function test_read_5work_3rdTooFewSpec (~)
            % Test reading a map file with five workspaces, third empty
            % Should simply be ignored and output has four workspaces
            f = @()IX_map.read_ascii ('map_5work_3rdTooFewSpec.map');
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_file_format');
            assertTrue(contains(ME.message, ...
                'Unexpected characters when expecting numeric data'))
        end
        
        function test_read_5work_3rdManyFewSpec (~)
            % Test reading a map file with five workspaces, third empty
            % Should simply be ignored and output has four workspaces
            f = @()IX_map.read_ascii ('map_5work_3rdTooManySpec.map');
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_file_format');
            assertTrue(contains(ME.message, ...
                'Too many spectrum numbers given for the workspace numbered'))
        end
        
        
        %------------------------------------------------------------------
        % Test save_ascii
        %------------------------------------------------------------------
        function test_write_read_0work (~)
            % Read a map file (tested elsewhere in this test that it works)
            wref = IX_map.read_ascii ('map_0work.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end
        
        function test_write_read_1work_0spec (~)
            % Read a map file (tested elsewhere in this test that it works)
            wref = IX_map.read_ascii ('map_1work_0spec.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end
        
        function test_write_5work_noneEmpty (~)
            % Read a map file (tested elsewhere in this test that it works)
            wref = IX_map.read_ascii ('map_5work_noneEmpty.txt');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end
        
        function test_write_5work_3rdEmpty (~)
            % Read a map file (tested elsewhere in this test that it works)
            wref = IX_map.read_ascii ('map_5work_3rdEmpty.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end
        
        function test_write_read_14work_18432spec (~)
            % Read a large map file 
            wref = IX_map.read_ascii ('map_14work_18432spec.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end
        
        function test_write_read_15work_18432spec_1st_empty (~)
            % Read a large map file 
            wref = IX_map.read_ascii ('map_15work_18432spec_1st_empty.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end
        
        function test_write_read_15work_18432spec_3rd_empty (~)
            % Read a large map file 
            wref = IX_map.read_ascii ('map_15work_18432spec_3rd_empty.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end
        
        function test_write_read_15work_18432spec_15th_empty (~)
            % Read a large map file 
            wref = IX_map.read_ascii ('map_15work_18432spec_15th_empty.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end

        
        %------------------------------------------------------------------
        % Test use of read_ascii when passing file name to constructor
        %------------------------------------------------------------------
        function test_read_2work_5and12spec_viaConstructor (~)
            % Test reading a map file with two workspaces, five and 12 spectra
            % We know this is correctly read using IX_map.read_ascii if the test
            % above has passed
            w = IX_map ('map_2work_5and12spec.map');
            wref = IX_map.read_ascii ('map_2work_5and12spec.map');
            assertEqual (w, wref)
        end
        
        function test_read_5work_3rdTooFewSpec_viaConstructor (~)
            % Test reading a map file with five workspaces, third empty
            % Should simply be ignored and output has four workspaces
            f = @()IX_map ('map_5work_3rdTooFewSpec.map');
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_file_format');
            assertTrue(contains(ME.message, ...
                'Unexpected characters when expecting numeric data'))
        end
        

        %------------------------------------------------------------------
        % Test combine
        %------------------------------------------------------------------
        function test_combine_1map (~)
            % Single input - output the same as input
            map1 = IX_map([11,12,30], 'wkno', [3,7,7]);
            
            mtot = combine(map1);
            assertEqual (mtot, map1)
        end
        
        function test_combine_2map_identical (~)
            % Two identical map files combined should be the original
            map1 = IX_map([11,12,30], 'wkno', [3,7,7]);
            
            mtot = combine(map1, map1);
            assertEqual (mtot, map1)
        end
        
        function test_combine_2map_noOverlap (~)
            % Two map files that have interleaved workspace numbers but no
            % shared spectra
            map1 = IX_map([11,12,30], 'wkno', [3,7,7]);
            map2 = IX_map([20,21,70], 'wkno', [5,8,8]); % no shared spectra
            mtot_ref = IX_map([11,20,12,30,21,70], 'wkno', [3,5,7,7,8,8]);
            
            mtot = combine(map1, map2);
            assertEqual (mtot, mtot_ref)
        end
        
        function test_combine_3map_overlap (~)
            % Three map files that share some workspace numbers
            map1 = IX_map([11,12,30], 'wkno', [3,7,7]);
            map2 = IX_map([20,21,70], 'wkno', [5,8,8]);
            % Shared workspaces and spectra with map1 and map2
            map3 = IX_map([12,12,21,1], 'wkno', [3,4,8,10]); 
            mtot_ref = IX_map([11,12,12,20,12,30,21,70,1], ...
                'wkno', [3,3,4,5,7,7,8,8,10]);
            
            mtot = combine(map1, map2, map3);
            assertEqual (mtot, mtot_ref)
        end
        
        function test_combine_2map_noOverlap_largeMaps (~)
            % Two map files read from file with large number of workspaces
            % Tests multiple line spectrum description with realistic case
            map1 = IX_map('map_14work_18432spec_select1to8work.map');
            map2 = IX_map('map_14work_18432spec_select9to14work.map');
            mtot_ref = IX_map('map_14work_18432spec.map');
            
            mtot = combine(map1, map2);
            assertEqual (mtot, mtot_ref)
        end

        
        %------------------------------------------------------------------
        % Test concatenate
        %------------------------------------------------------------------
        function test_concatenate_1map (~)
            % Single input - output the same as input
            map1 = IX_map([11,12,30], 'wkno', [3,7 7]);
            
            mtot = concatenate(map1);
            assertEqual (mtot, map1)
        end
        
        function test_concatenate_2map_identical (~)
            % Two identical map files concatenated should be double the number
            % of spectra with an offset second set of workspaces
            map1 = IX_map([11,12,30], 'wkno', [3,7 7]);
            mtot_ref = IX_map([11,12,30,11,12,30], 'wkno', [3,7,7,8,12,12]);
            
            mtot = concatenate(map1, map1);
            assertEqual (mtot, mtot_ref)
        end
        
        function test_concatenate_2map_noOverlap (~)
            % Two map files that have interleaved workspace numbers but no
            % shared spectra
            map1 = IX_map([11,12,30], 'wkno', [3,7,7]);
            map2 = IX_map([20,21,70], 'wkno', [5,8,8]); % no shared spectra
            mtot_ref = IX_map([11,12,30,20,21,70], 'wkno', [3,7,7,8,11,11]);
            
            mtot = concatenate(map1, map2);
            assertEqual (mtot, mtot_ref)
        end
        
        function test_concatenate_3map_overlap (~)
            % Three map files that share some workspace numbers
            map1 = IX_map([11,12,30], 'wkno', [3,7,7]);
            map2 = IX_map([20,21,70], 'wkno', [5,8,8]);
            % Shared workspaces and spectra with map1 and map2
            map3 = IX_map([12,12,21,1], 'wkno', [3,4,8,10]); 
            mtot_ref = IX_map([11,12,30,20,21,70,12,12,21,1], ...
                'wkno', [3,7,7,8,11,11,12,13,17,19]);
            
            mtot = concatenate(map1, map2, map3);
            assertEqual (mtot, mtot_ref)
        end
        
        function test_concatenate_3map_workspaceGaps (~)
            % Three map files with workspace numbers that are distinct and not
            % interleaved
            map1 = IX_map([11,12,30], 'wkno', [3,5,5]);
            map2 = IX_map([20,21,70], 'wkno', [6,8,8]);
            % Shared workspaces and spectra with map1 and map2
            map3 = IX_map([12,12,21,1], 'wkno', [10,10,13,13]); 
            mtot_ref = IX_map([11,12,30,20,21,70,12,12,21,1], ...
                'wkno', [3,5,5,6,8,8,10,10,13,13]);
            
            mtot = concatenate(map1, map2, map3);
            assertEqual (mtot, mtot_ref)
        end
        
        
        %------------------------------------------------------------------
        % Test multiple lines equivalent to concatenate
        %------------------------------------------------------------------
        function test_multiline_concatenate (~)
            map1 = IX_map(11, 20, -4);
            map2 = IX_map(101, 200, 7);
            map3 = IX_map(201, 240, 13);
            % Put all three maps into one all
            map = IX_map([11,101,201], [20,200,240], [-4,7,13]);
            
            % Reference map using combine method
            map_ref = concatenate(map1, map2, map3);
            
            assertEqual(map, map_ref)
        end
        
        function test_multiline_combine (~)
            map1 = IX_map(11, 20, -4);
            map2 = IX_map(101, 200, 7);
            map3 = IX_map(201, 240, 13);
            % Put all three maps into one all
            % Need to give wkno_beg(1) = NaN, because if we give it the value 1 then, because
            % the value of wkno_dcn is negative (as determined from the sign of step), the
            % workspace range will count backwards: 1, 0 ,-1,... for the first map. THis
            % throws an error.
            map = IX_map([11,101,201], [20,200,240], [-4,7,13], 'wkno', [NaN, 1, 1]);
            
            % Reference map using combine method
            map_ref = combine(map1, map2, map3);
            
            assertEqual(map, map_ref)
        end
        
        function test_multiline_combine_wkno_begNotNeeded (~)
            map1 = IX_map(11, 20, 4);
            map2 = IX_map(101, 200, 7);
            map3 = IX_map(201, 240, 13);
            % In this case, the first workspace has wkno_dcn positive, so we can set the
            % initial workspace number as 1. Because this is the case for all workspaces we
            % only need to give skno_beg as the scalar value 1.
            map = IX_map([11,101,201], [20,200,240], [4,7,13], 'wkno', 1);
            
            % Reference map using combine method
            map_ref = combine(map1, map2, map3);
            
            assertEqual(map, map_ref)
        end
        
        
        %------------------------------------------------------------------
        % Test mask
        %------------------------------------------------------------------
        function test_mask_emptyMap_noMask (~)
            % Empty map and no spectra being masked
            map = IX_map();
            
            map_out = mask(map, []);
            assertEqual (map_out, map)
        end
                
        function test_mask_3workNoneEmpty_noMask (~)
            % No spectra being masked
            wkno = [4,6,9];
            ns = [2,3,1];
            s = [15,19,4,14,19,17];
            map = IX_map(s, 'wkno', wkno, 'ns', ns);
            
            map_out = mask(map, []);
            assertEqual (map_out, map)
        end
                
        function test_mask_3work1empty_noMask (~)
            % No spectra being masked
            % [Map has an empty workspace and a spectrum mapped into two workspaces]
            wkno = [4,6,1,9];
            ns = [2,3,0,1];
            s = [15,19,4,14,19,17];
            map = IX_map(s, 'wkno', wkno, 'ns', ns);
            
            map_out = mask(map, []);
            assertEqual (map_out, map)
        end
                
        function test_mask_3work1empty_1Mask_1workReduced (~)
            % Mask one spectrum, but leave the relevant workspace non-empty
            % [Map has an empty workspace and a spectrum mapped into two workspaces]
            wkno = [4,6,1,9];
            ns = [2,3,0,1];
            s = [15,19,4,14,19,17];
            map = IX_map(s, 'wkno', wkno, 'ns', ns);
            
            map_out = mask(map, 15);
            
            map_ref = IX_map([19,4,14,19,17], 'wkno', wkno, 'ns', [1,3,0,1]);
            assertEqual (map_out, map_ref)
        end
                
        function test_mask_3work1empty_1Mask_2workReduced (~)
            % Mask one spectrum shared between two workspaces, but leave the
            % relevant workspaces non-empty
            % [Map has an empty workspace and a spectrum mapped into two workspaces]
            wkno = [4,6,1,9];
            ns = [2,3,0,1];
            s = [15,19,4,14,19,17];
            map = IX_map(s, 'wkno', wkno, 'ns', ns);
            
            map_out = mask(map, 19);
            
            map_ref = IX_map([15,4,14,17], 'wkno', wkno, 'ns', [1,2,0,1]);
            assertEqual (map_out, map_ref)
        end
                
        function test_mask_3work1empty_3Mask_1workReduced2workEmpty (~)
            % Mask three spectra, reduces one workspace and empties two
            % [Map has an empty workspace and a spectrum mapped into two workspaces]
            wkno = [4,6,1,9];
            ns = [2,3,0,1];
            s = [15,19,4,14,19,17];
            map = IX_map(s, 'wkno', wkno, 'ns', ns);
            
            map_out = mask(map, [15,17,19]);
            
            map_ref = IX_map([4,14], 'wkno', wkno, 'ns', [0,2,0,0]);
            assertEqual (map_out, map_ref)
        end
                
        function test_mask_3work1empty_allMask (~)
            % Mask all spectra. Note that this means four empty workspaces, not
            % an empty map.
            % [Map has an empty workspace and a spectrum mapped into two workspaces]
            wkno = [4,6,1,9];
            ns = [2,3,0,1];
            s = [15,19,4,14,19,17];
            map = IX_map(s, 'wkno', wkno, 'ns', ns);
            
            map_out = mask(map, [15,19,4,14,19,17]);
            
            assertEqual(map_out.wkno, [1,4,6,9]);
            assertEqual(map_out.ns, [0,0,0,0])
            assertEqual(map_out.s, zeros(1,0));
        end

        
        %------------------------------------------------------------------
        % Test section
        %------------------------------------------------------------------
        function test_section_0work_emptyKeep (~)
            % Should return the same as the input
            map = IX_map();
            map_out = section(map, []);
            assertEqual(map_out, map)
        end
        
        function test_section_2work_0keep (~)
            % Should return empty map
            map = IX_map([2,4,7,10,14], 'wkno', [104,106], 'ns', [3,2]);
            map_out = section(map, []);
            assertEqual(map_out, IX_map())
        end

        function test_section_2work_1keep (~)
            % Keeps one of two workspaces
            map = IX_map([2,4,7,10,14], 'wkno', [104,106], 'ns', [3,2]);
            map_out = section(map, 106);
            map_ref = IX_map([10,14], 'wkno', 106, 'ns', 2);
            assertEqual(map_out, map_ref)
        end
        
        function test_section_2work_1keep_ERROR (~)
            % Keeps one of two workspaces
            % Give the workspace to keep as 2 (second workspace), not 106 (the
            % number of the second workspace)
            map = IX_map([2,4,7,10,14], 'wkno', [104,106], 'ns', [3,2]);
            f = @()section(map, 2);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ['Workspace number 2 and possibly ',...
                'others to be kept are not one of the input workspace numbers']))
        end
        
        function test_section_2work_2keep (~)
            % Keeps both workspaces - output should be same as input
            map = IX_map([2,4,7,10,14], 'wkno', [104,106], 'ns', [3,2]);
            map_out = section(map, [106,104]);
            assertEqual(map_out, map)
        end
        
        function test_section_5work_3rdEmpty_2nd3rdKeep (~)
            % Keep two workspaces, one of which is empty
            map = IX_map([21:25, 31:36, 51:58, 61:69], 'wkno', [2,3,4,5,6], 'ns', [5,6,0,8,9]);
            map_out = section(map, [3,4]);
            map_ref = IX_map(31:36, 'wkno', [3,4], 'ns', [6,0]);
            assertEqual(map_out, map_ref)
        end
        
        function test_section_5work_3rdEmpty_3rd4thKeep (~)
            % Keep two workspaces, one of which is empty
            % Read a map file (tested elsewhere in this test that it works)
            map = IX_map([21:25, 31:36, 51:58, 61:69], 'wkno', [2,3,4,5,6], 'ns', [5,6,0,8,9]);
            map_out = section(map, [4,5]);
            map_ref = IX_map(51:58, 'wkno', [4,5], 'ns', [0,8]);
            assertEqual(map_out, map_ref)
        end
        
        function test_section_5work_3rdEmpty_3rdKeep (~)
            % Keep only the empty workspace
            % Read a map file (tested elsewhere in this test that it works)
            map = IX_map([21:25, 31:36, 51:58, 61:69], 'wkno', [2,3,4,5,6], 'ns', [5,6,0,8,9]);
            map_out = section(map, 4);
            map_ref = IX_map([], 'wkno', 4, 'ns', 0);
            assertEqual(map_out, map_ref)
        end

        
        %------------------------------------------------------------------
        % Test product
        %------------------------------------------------------------------        
        function test_product_0work_0work (~)
            % The result should be an empty map
            mapA = IX_map (); 
            mapB = IX_map ();
            map_out = product(mapB, mapA);
            
            map_ref = IX_map();
            assertEqual(map_out, map_ref)
        end
        
        function test_product_0work_manyWorkmanySpec (~)
            % Second map is empty, so the first map in the product is
            % irrelevant, because the second has no spectra. The result shoudl
            % be an empty map
            mapA = IX_map( [[], [2,3,4], [], [5,6], [7,8,9], []],...
                'wkno',    [11,    22,   33,   44,    55,    66],...
                'ns',      [ 0,     3,    0,    2,     3,     0]);   
            mapB = IX_map ();
            map_out = product(mapB, mapA);
            
            map_ref = IX_map();
            assertEqual(map_out, map_ref)
        end
        
        function test_product_1work0spec_0work (~)
            % Second map does not use the first map, so in the product is
            % irrelevant, because the second has no spectra. The result should
            % be the same as the second map            mapA = IX_map (); 
            mapA = IX_map();
            mapB = IX_map ([], 'wkno', 99, 'ns', 0);
            map_out = product(mapB, mapA);
            
            assertEqual(map_out, mapB)
        end
        
        function test_product_manyWork0spec_manyWorkManySpec (~)
            % Second map does not use the first map, so in the product is
            % irrelevant, because the second has no spectra. The result should
            % be the same as the second map
            mapA = IX_map( [[], [2,3,4], [], [5,6], [7,8,9], []],...
                'wkno',    [11,    22,   33,   44,    55,    66],...
                'ns',      [ 0,     3,    0,    2,     3,     0]);   
            mapB = IX_map ([], 'wkno', [99,100,101], 'ns', [0,0,0]);
            map_out = product(mapB, mapA);
            
            assertEqual(map_out, mapB)
        end
        
        function test_product_manyWorkManySpec_manyWork_OP_manyWork0spec (~)
            % Output should have zero spectra 
            mapA = IX_map( [[], [2,3,4], [], [5,6], [7,8,9], []],...
                'wkno',    [11,    22,   33,   44,    55,    66],...
                'ns',      [ 0,     3,    0,    2,     3,     0]);   
            mapB = IX_map ([11,33,66,11,33,66], 'wkno', [99,100,101], 'ns', [2,1,3]);
            map_out = product(mapB, mapA);
            
            map_ref = IX_map([], 'wkno', [99,100,101], 'ns', [0,0,0]);
            assertEqual(map_out, map_ref)
        end
        
        function test_product_1work1spec_1work3spec (~)
            % map with one workspace further mapped by a map with one spectrum
            mapA = IX_map([2,3,4], 'wkno',33, 'ns',3);
            mapB = IX_map(33, 'wkno', 2, 'ns', 1);
            map_out = product(mapB, mapA);
            
            map_ref = IX_map([2,3,4], 'wkno',2, 'ns',3);
            assertEqual(map_out, map_ref)
        end
        
        function test_product_3work1empty_1work3spec (~)
            % map with one workspace further mapped by a map with three spectra,
            % one of which is empty
            mapA = IX_map([2,3,4], 'wkno',33, 'ns',3);
            mapB = IX_map([33,33], 'wkno', [2,12,22], 'ns', [1,0,1]);
            map_out = product(mapB, mapA);
            
            map_ref = IX_map([2,3,4,2,3,4], 'wkno',[2,12,22], 'ns',[3,0,3]);
            assertEqual(map_out, map_ref)
        end
        
        function test_product_expectedWorkspaceMissingInFirstMap_ERROR (~)
            % map with one workspace further mapped by a map with three spectra,
            % one of which is empty
            mapA = IX_map([2,3,4], 'wkno',33, 'ns',3);
            mapB = IX_map([33,32], 'wkno', [2,12,22], 'ns', [1,0,1]);
            f = @()product(mapB, mapA);
            
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ['The left-hand map refers to at ',...
                'least one workspace (32)']))
        end
        
        function test_product_manyWorkManySpec_manyWorkManySpec (~)
            % map with multiple workspaces, some empty,further mapped by a map
            % with multiple workspace, some of which are empty, others map
            % together workspaces from the first map which are variously empty,
            % mixed empty and non-empty, or none empty.
            % Provides a tough test of the re-mapping algorithm.
            mapA = IX_map( [[], [2,3,4], [], [5,6], [7,8,9], []],...
                'wkno',    [11,    22,   33,   44,    55,    66],...
                'ns',      [ 0,     3,    0,    2,     3,     0]);
            
            mapB = IX_map( [33,   [],  [44,11,22],   11,  33,66,    22,55,  11,33,66],...
                'wkno',    [111, 222,     333,       444,  555,      666     777],...
                'ns',       [1,    0,       3,        1,    2,        2,      3]);
            
            map_out = product(mapB, mapA);
            
            map_ref = IX_map([2,3,4,5,6,2,3,4,7,8,9],...
                'wkno', [111,222,333,444,555,666,777],...
                'ns', [0,0,5,0,0,6,0]);
            assertEqual(map_out, map_ref)
        end

    end
end
