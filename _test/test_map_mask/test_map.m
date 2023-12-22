classdef test_map < TestCase
    % test_mask  Tests IX_mask class
    
    methods
        %--------------------------------------------------------------------------
        % Test constructor without repeat blocks
        %--------------------------------------------------------------------------
        function test_1Spec_1WorkDefault (~)
            % Single spectrum to default single workspace
            isp = 17;
            map = IX_map(isp);
            assertEqual(map.s, 17);
            assertEqual(map.w, 1);  % default is workspace 1
        end
        
        function test_1Spec_1Work (~)
            % Single spectrum to single workspace
            isp = 17;
            map = IX_map(isp, 'wkno', 5);
            assertEqual(map.s, 17);
            assertEqual(map.w, 5);
        end
        
        function test_manySpec_1Work (~)
            % Many spectra to single workspace
            isp = [14;19;17];
            iwk = 5;
            map = IX_map(isp, 'wkno', iwk);
            assertEqual(map.s, [14,17,19]);     % sorted as all in one workspace
            assertEqual(map.w, [5,5,5]);
        end
        
        function test_manySpec_manyWorkDefault (~)
            % Many spectra to default 1:1 mapping
            isp = [14;19;17];
            map = IX_map(isp);
            assertEqual(map.s, [14,19,17]);
            assertEqual(map.w, [1,2,3]);
        end
        
        function test_manySpec_manyWork (~)
            % Many spectra to 1:1 workspace mapping
            isp = [14;19;17];
            iwk = [6,4,9];
            map = IX_map(isp, 'wkno', iwk);
            assertEqual(map.s, [19,14,17]);     % sorted by workspace number
            assertEqual(map.w, [4,6,9]);        % sorted
        end
        
        function test_manySpec_manyWork_many2one (~)
            % Many spectra to workspaces mapping; not 1:1
            isp = [14;19;17;15;4];
            iwk = [6,4,9,4,6];
            map = IX_map(isp, 'wkno', iwk);
            assertEqual(map.s, [15,19,4,14,17]);    % sorted by workspace number
            assertEqual(map.w, [4,4,6,6,9]);        % sorted
            assertEqual(map.wkno, [4,6,9]);
            assertEqual(map.ns, [2,2,1])
        end
        
        function test_negativeSpec_ERROR (~)
            % A negative spectrum number
            isp = [14;-19;17];
            iwk = [6,4,9];
            f = @()IX_map(isp, 'wkno', iwk);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, 'Spectrum numbers must all be >= 1'))
        end
        
        function test_negativeWork_ERROR (~)
            % A negative workspace number
            isp = [14;19;17];
            iwk = [6,-4,9];
            f = @()IX_map(isp, 'wkno', iwk);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, 'Workspace numbers must all be >= 1'))
        end
        
        function test_SpecAndWorkArrayMismatch_ERROR (~)
            % A negative workspace number
            isp = [14;19;17];
            iwk = [6,9];
            f = @()IX_map(isp, 'wkno', iwk);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ...
                'Workspace array must be scalar or have same length as spectrum array'))
        end
        
        
        %--------------------------------------------------------------------------
        % Test constructor with repeat blocks
        %--------------------------------------------------------------------------
        function test_1Spec_1WorkDefault_3Repeat (~)
            % Single spectrum to default single workspace
            isp = 17;
            nrepeat = 3;
            delta_isp = 10;
            delta_iw = 1;
            map = IX_map(isp, 'repeat', [nrepeat, delta_isp, delta_iw]);
            assertEqual(map.s, [17, 27, 37]);
            assertEqual(map.w, [1, 2, 3]);  % default is workspace 1
        end
        
        function test_1Spec_1Work_3Repeat_negSpec_ERROR (~)
            % Single spectrum to single workspace
            isp = 17;
            iw = 5;
            nrepeat = 3;
            delta_isp = -10;
            delta_iw = 1;
            f = @()IX_map(isp, 'wkno', iw, 'repeat', [nrepeat, delta_isp, delta_iw]);
            ME = assertExceptionThrown (f, 'HERBERT:IX_map:invalid_argument');
            assertTrue(contains(ME.message, ['Spectrum array constructed for ',...
                'at least one repeated array includes zero or negative spectrum numbers']))
        end
        
        
        %------------------------------------------------------------------
        % Test reading from ASCII file (.map file)
        %------------------------------------------------------------------
        function test_read_0work (~)
            % Test reading a map file with explicitly 0 workspaces
            w = IX_map.read_ascii ('map_0work.map');
            wref = IX_map ();
            assertEqual (w, wref, 'File and array constructors not equivalent')
        end
        
        function test_read_1work_0spec (~)
            % Test reading a map file with one workspace, no spectra
            w = IX_map.read_ascii ('map_1work_0spec.map');
            wref = IX_map ();
            assertEqual (w, wref, 'File and array constructors not equivalent')
        end
        
        function test_read_1work_1spec (~)
            % Test reading a map file with one workspace, one spectrum
            w = IX_map.read_ascii ('map_1work_1spec.map');
            wref = IX_map (5, 'wkno', 99);
            assertEqual (w, wref, 'File and array constructors not equivalent')
        end
        
        function test_read_1work_5spec (~)
            % Test reading a map file with one workspace, five spectra
            w = IX_map.read_ascii ('map_1work_5spec.map');
            wref = IX_map ([2,3,4,11,13], 'wkno', 99);
            assertEqual (w, wref, 'File and array constructors not equivalent')
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
            is = [2,3,4,11,13,1,3,5,7,16,19,22,23,24,25,36,40];
            iw = [99*ones(1,5), 23*ones(1,12)];
            wref = IX_map (is, 'wkno', iw);
            assertEqual (w, wref, 'File and array constructors not equivalent')
        end
        
        function test_read_5work_noneEmpty (~)
            % Test reading a map file with five workspaces, none empty
            % It has nopn-standard extension (*.txt, not *.map)
            w = IX_map.read_ascii ('map_5work_noneEmpty.txt');
            is = [21:25, 31:36, 41:47, 51:58, 61:69];
            iw = [2*ones(1,5), 3*ones(1,6), 4*ones(1,7), 5*ones(1,8), 6*ones(1,9)];
            wref = IX_map (is, 'wkno', iw);
            assertEqual (w, wref, 'File and array constructors not equivalent')
        end
        
        function test_read_5work_1stEmpty (~)
            % Test reading a map file with five workspaces, first one empty
            % Should simply be ignored and output has four workspaces
            w = IX_map.read_ascii ('map_5work_1stEmpty.map');
            is = [31:36, 41:47, 51:58, 61:69];
            iw = [3*ones(1,6), 4*ones(1,7), 5*ones(1,8), 6*ones(1,9)];
            wref = IX_map (is, 'wkno', iw);
            assertEqual (w, wref, 'File and array constructors not equivalent')
        end
        
        function test_read_5work_3rdEmpty (~)
            % Test reading a map file with five workspaces, third empty
            % Should simply be ignored and output has four workspaces
            w = IX_map.read_ascii ('map_5work_3rdEmpty.map');
            is = [21:25, 31:36, 51:58, 61:69];
            iw = [2*ones(1,5), 3*ones(1,6), 5*ones(1,8), 6*ones(1,9)];
            wref = IX_map (is, 'wkno', iw);
            assertEqual (w, wref, 'File and array constructors not equivalent')
        end
        
        function test_read_5work_5thEmpty (~)
            % Test reading a map file with five workspaces, last empty
            % Should simply be ignored and output has four workspaces
            w = IX_map.read_ascii ('map_5work_5thEmpty.map');
            is = [21:25, 31:36, 41:47, 51:58];
            iw = [2*ones(1,5), 3*ones(1,6), 4*ones(1,7), 5*ones(1,8)];
            wref = IX_map (is, 'wkno', iw);
            assertEqual (w, wref, 'File and array constructors not equivalent')
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
        % Test write to ASCII file
        %------------------------------------------------------------------
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
        
        function test_write_read_14work_18432spec (~)
            % Read a map file (tested elsewhere in this test that it works)
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
            % Read a map file (tested elsewhere in this test that it works)
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
            % Read a map file (tested elsewhere in this test that it works)
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
            % Read a map file (tested elsewhere in this test that it works)
            wref = IX_map.read_ascii ('map_15work_18432spec_15th_empty.map');
            % Save to temporary .map file
            test_file = fullfile (tmp_dir(), 'test_map_IO.map');
            cleanup = onCleanup(@()delete(test_file));
            save_ascii (wref, test_file)
            % Recover map
            w = read_map (test_file);
            assertEqual (w, wref)
        end


%       *** Tests of IX_map are failing
%       *** IX_mask with file; also implement for IX_map?
%       *** refactor IX_map combine, mask_map, combine (if need them!)
        
    end
    
end



% % -----------------------------------------------------------------------------
% % Test combine
% % ------------
% wref=IX_map('map_14.map');
% w1=IX_map('map_1to8.map');
% w2=IX_map('map_9to14.map');
% wrefnam=IX_map('map_14.map','wkno');
% w1nam=IX_map('map_1to8.map','wkno');
% w2nam=IX_map('map_9to14.map','wkno');
%
% % Trivial case of one map
% wcomb=combine(w1);
% if ~isequal(w1,wcomb), assertTrue(false,'Error combining two maps'), end
%
% % Combine two maps
% wcomb=combine(w1,w2);
% if ~isequal(wref,wcomb), assertTrue(false,'Error combining two maps'), end
%
% % Try to combine workspaces with shared spectra
% try
%     wcomb_bad=combine(w1,wref);
%     ok=false;
% catch
%     ok=true;
% end
% if ~ok, assertTrue(false,'Should have failed because shared spectra'), end
%
% % Combine workspaces with names
% wcomb=combine(w1nam,w2nam,'wkno');
% if ~isequal(wrefnam,wcomb), assertTrue(false,'Error combining two maps'), end
%
% % A severe test:
% m1=IX_map({[11,12,13],[21,22]});
% m2=IX_map({[31,32,33,34],[41,42],51},'wkno',[2,99,5]);
% m3=IX_map({61,[72,73],[81,82],(91:95)});
% mtot=IX_map({[11,12,13],[21,22],[31,32,33,34],[41,42],51,61,[72,73],[81,82],(91:95)});
% mtotnam=IX_map({[11,12,13],[21,22],[31,32,33,34],[41,42],51,61,[72,73],[81,82],(91:95)},'wkno',[1,3,2,99,5,4,6,7,8]);
%
% wcomb=combine(m1,m2,m3,'wkno');
% if ~isequal(mtotnam,wcomb), assertTrue(false,'Error combining three maps'), end
%
% wcomb=combine(m1,m2,m3);
% if ~isequal(mtot,wcomb), assertTrue(false,'Error combining three maps'), end
%
%
% % -----------------------------------------------------------------------------
% % Test mask_map
% % -------------
% wref=IX_map('map_14.map');
% wmsk=mask_map(wref,[35000:40000,5000:20000]);
% wmskref=IX_map('map_14_msk.map');
% if ~isequal(wmsk,wmskref), assertTrue(false,'Error masking map object'), end
%
