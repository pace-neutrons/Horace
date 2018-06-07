classdef test_gen_sqw_accumulate_sqw_nomex < ...
        gen_sqw_accumulate_sqw_common_test & gen_sqw_common_config
    
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
            obj = obj@gen_sqw_common_config(0,0,0,-1);
            obj = obj@gen_sqw_accumulate_sqw_common_test(test_name,'nomex');
        end
        
        %
        function obj=test_wrong_params_gen_sqw(obj,varargin)
            if nargin > 1  % running in single test method mode.
                obj.setUp();
                co1 = onCleanup(@()obj.tearDown());
                
            end
            % something wrong with this test -- it was with 'replicate'
            % option and apparemtly failing
            sqw_file_15456=fullfile(tempdir,['sqw_123456_',obj.test_pref,'.sqw']);  % output sqw file which should never be created
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            spe_files = obj.spe_file([1,5,4,5,6]);
            [fpath,fname]=fileparts(spe_files{5});
            cod = onCleanup(@()delete(fullfile(fpath,[fname,'_2.tmp'])));
            
            try
                gen_sqw (spe_files, '', sqw_file_15456, efix([1,5,4,5,6]),...
                    emode, alatt, angdeg, u, v, psi([1,5,4,5,6]), omega([1,5,4,5,6]),...
                    dpsi([1,5,4,5,6]), gl([1,5,4,5,6]), gs([1,5,4,5,6]), 'replicate');
                ok=false;
            catch ME
                ok=true;
                assertEqual(ME.identifier,'WRITE_NSQW_TO_SQW:invalid_argument')
                
            end
            assertTrue(ok,'Should have failed because of repeated spe file name and parameters');
        end
        %
        function obj=test_wrong_params_accum_sqw(obj)
            %-------------------------------------------------------------
            %-------------------------------------------------------------
            sqw_file_accum=fullfile(tempdir,['sqw_accum_',obj.test_pref,'.sqw']);  % output sqw file which should never be created
            
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            
            % Repeat a file
            spe_accum={obj.spe_file{1},'',obj.spe_file{5},obj.spe_file{4},obj.spe_file{5},obj.spe_file{6}};
            try
                accumulate_sqw (spe_accum, '', sqw_file_accum,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
                ok=false;
            catch ME
                ok=true;
                assertEqual(ME.identifier,'GEN_SQW:invalid_argument');
            end
            assertTrue(ok,'Should have failed because of repeated spe file name');
            
        end
        
        
    end
end
