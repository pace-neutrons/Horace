classdef test_gen_sqw_accumulate_sqw_nomex < ...
        gen_sqw_accumulate_sqw_tests_common & gen_sqw_common_config

    % Series of tests of gen_sqw and associated functions
    % when mex code is disabled or not available
    %
    % Optionally writes results to output file to compare with previously
    % saved sample test results
    %
    % Usage:
    %---------------------------------------------------------------------
    %1) Normal usage:
    % Run all unit tests and compare their results with previously saved
    % results stored in test_gen_sqw_accumulate_sqw_output.mat file
    % located in the same folder as this function:
    %
    %>>runtests test_gen_sqw_accumulate_sqw_nomex
    %---------------------------------------------------------------------
    %2) Run particular test case from the suite:
    %
    %>>tc = test_gen_sqw_accumulate_sqw_nomex();
    %>>tc.test_[particular_test_name] e.g.@
    %>>tc.test_gen_sqw_threading_mex();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_gen_sqw_accumulate_sqw_nomex ('save');
    %>>tc.save():


    properties
    end

    methods
        function obj=test_gen_sqw_accumulate_sqw_nomex(test_name)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %>> runtests test_gen_sqw_accumulate_sqw    % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same folder as this function
            %>>tc=test_gen_sqw_accumulate_sqw ('save')  % Stores sample
            %>>tc.save()                                %results into tmp folder
            %
            % Reads previously created test data sets.
            % constructor
            if ~exist('test_name','var')
                test_name = 'test_gen_sqw_accumulate_sqw_nomex';
            end
            obj = obj@gen_sqw_common_config(0,0,'matlab',-1);
            obj = obj@gen_sqw_accumulate_sqw_tests_common(test_name,'nomex');
        end
        %
        function test_gen_sqw_works_with_existing_tmp(obj,varargin)
            if nargin > 1  % running in single test method mode.
                obj.setUp();
                co1 = onCleanup(@()obj.tearDown());
            end
            sqw_file_1234=fullfile(tmp_dir,['sqw_1234_',obj.test_pref,'.sqw']);  % output sqw file which should never be created
            clFile = onCleanup(@()obj.delete_files(sqw_file_1234));
            clWarn = set_temporary_warning('off','HORACE:push_warning','HORACE:valid_tmp_files_exist');
            clConf = set_temporary_config_options('hor_config','delete_tmp',true,'log_level',1);

            [~,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            spe_files1 = obj.spe_file([1,2,3,4]);
            spe_files1{4} = 'missing.nxspe';
            spe_files2 = obj.spe_file([1,2,3,4]);
            [tmp_files,grid_size,~,pix_db_range] =gen_sqw (spe_files1, '', sqw_file_1234, efix([1,2,3,4]),...
                emode, alatt, angdeg, u, v, psi([1,2,3,4]), omega([1,2,3,4]),...
                dpsi([1,2,3,4]), gl([1,2,3,4]), gs([1,2,3,4]),'tmp_only','accumulate');
            assertEqual(numel(tmp_files),3);
            for i=1:numel(tmp_files)
                assertTrue(isfile(tmp_files{i}))
            end
            warning('HORACE:push_warning','push warning issued to ensure correct warning will appear below');
            [tmp_files,~,~,wout_sqw] =gen_sqw (spe_files2, '', sqw_file_1234, efix([1,2,3,4]),...
                emode, alatt, angdeg, u, v, psi([1,2,3,4]), omega([1,2,3,4]),...
                dpsi([1,2,3,4]), gl([1,2,3,4]), gs([1,2,3,4]),grid_size,pix_db_range);
            [w_mess,warn_id] = lastwarn;
            assertEqual(warn_id,'HORACE:valid_tmp_files_exist')
            assertTrue(strncmp(w_mess(2:end),'*** There are 3 previously generated tmp files present',23))            
            assertEqual(numel(tmp_files),4);
            for i=1:numel(tmp_files)
                % all tmp were deleted when sqw was successfully generated
                % or just gen_sqw deletes files when finishes
                assertFalse(isfile(tmp_files{i}))
            end

            assertTrue(isa(wout_sqw,'sqw'))
            assertEqual(wout_sqw.data.img_range,pix_db_range);
        end
        function test_calc_qw_pixels2_works_4different_energies(obj,varargin)
            if nargin > 1  % running in single test method mode.
                obj.setUp();
                co1 = onCleanup(@()obj.tearDown());
            end
            sqw_file_1234=fullfile(tmp_dir,['sqw_1234_calc_qw',obj.test_pref,'.sqw']);
            clFile = onCleanup(@()obj.delete_files(sqw_file_1234));
            clWarn = set_temporary_warning('off','HORACE:push_warning','HORACE:valid_tmp_files_exist');

            [~,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            spe_files1 = obj.spe_file([1,2,3,4]);

            gen_sqw (spe_files1, '', sqw_file_1234, efix([1,2,3,4]),...
                emode, alatt, angdeg, u, v, psi([1,2,3,4]), omega([1,2,3,4]),...
                dpsi([1,2,3,4]), gl([1,2,3,4]), gs([1,2,3,4]));

            tob = read_sqw(sqw_file_1234);
            tp  = tob.calculate_qw_pixels2(false,true);

            assertEqualToTol(tob.pix.coordinates,tp,[2.e-7,2.e-7]);
        end
        
        %
        function test_wrong_params_gen_sqw(obj,varargin)
            if nargin > 1  % running in single test method mode.
                obj.setUp();
                co1 = onCleanup(@()obj.tearDown());
            end
            % something wrong with this test -- it was with 'replicate'
            % option and apparently failing
            sqw_file_15456=fullfile(tmp_dir,['sqw_123456_',obj.test_pref,'.sqw']);  % output sqw file which should never be created

            [~,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            spe_files = obj.spe_file([1,5,4,5,6]);

            try
                gen_sqw (spe_files, '', sqw_file_15456, efix([1,5,4,5,6]),...
                    emode, alatt, angdeg, u, v, psi([1,5,4,5,6]), omega([1,5,4,5,6]),...
                    dpsi([1,5,4,5,6]), gl([1,5,4,5,6]), gs([1,5,4,5,6]));
                ok=false;
            catch ME
                ok=true;
                assertEqual(ME.identifier,'HORACE:algorithms:invalid_argument')
            end
            assertTrue(ok,'Should have failed because of repeated spe file name and parameters');
        end
        %
        function test_wrong_params_accum_sqw(obj)
            %-------------------------------------------------------------
            %-------------------------------------------------------------
            sqw_file_accum=fullfile(tmp_dir,['sqw_accum_',obj.test_pref,'.sqw']);  % output sqw file which should never be created


            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);

            % Repeat a file
            spe_accum={obj.spe_file{1},'',obj.spe_file{5},obj.spe_file{4},obj.spe_file{5},obj.spe_file{6}};
            try
                accumulate_sqw (spe_accum, '', sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
                ok=false;
            catch ME
                ok=true;
                assertEqual(ME.identifier,'HORACE:algorithms:invalid_argument');
            end
            assertTrue(ok,'Should have failed because of repeated spe file name');
        end
    end
end
