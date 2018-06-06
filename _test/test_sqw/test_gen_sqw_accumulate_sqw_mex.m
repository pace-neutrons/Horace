classdef test_gen_sqw_accumulate_sqw_mex < gen_sqw_accumulate_sqw_common_test
    % Series of tests of gen_sqw and associated functions generated using
    % mex code.
    %
    % Optionally writes results to output file to compare with previously
    % saved sample test results
    %---------------------------------------------------------------------
    % Usage:
    %
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
    %>>tc.test_[particular_test_name] e.g.:
    %>>tc.test_gen_sqw();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_gen_sqw_accumulate_sqw_nomex ('save');
    %>>tc.save():
    
    properties
        set_single_theaded
        set_mex
    end
    
    methods
        function obj=test_gen_sqw_accumulate_sqw_mex(varargin)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same folder as this function
            %   >>tc=test_gen_sqw_accumulate_sqw ('save')
            %  >>tc.save()                              % Save to test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.
            
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj = obj@gen_sqw_accumulate_sqw_common_test(name,'mex');
            
            [~,n_errors]=check_horace_mex();
            if n_errors>0
                obj.skip_test = true;
            else
                hc = obj.initial_config.hc;
                hpc = obj.initial_config.hpc;
                if hc.use_mex
                    obj.set_mex = false;
                else
                    obj.set_mex = true;
                end
                if hpc.accum_in_separate_process
                    obj.set_single_theaded = true;
                else
                    obj.set_single_theaded = false;
                end
            end
            
            
        end
        function setUp(obj)
            if ~obj.skip_test
                if obj.set_mex
                    hc = hor_config;
                    hc.use_mex = true;
                end
                if obj.set_single_theaded
                    hpcc = hpc_config;
                    hpcc.accum_in_separate_process = false;
                end
            end
        end
        %
        function tearDown(obj)
            if ~obj.skip_test
                if obj.set_mex
                    hc = hor_config;
                    hc.use_mex = false;
                end
                if obj.set_single_theaded
                    hpcc = hpc_config;
                    hpcc.accum_in_separate_process = true;
                end
                
            end
        end
        %
        function obj=test_wrong_params_gen_sqw(obj)
            % something wrong with this test -- it was with 'replicate'
            % option and apparemtly failing
            sqw_file_15456=fullfile(tempdir,['sqw_123456_',obj.test_pref,'.sqw']);  % output sqw file which should never be created
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            try
                gen_sqw (obj.spe_file([1,5,4,5,6]), '', sqw_file_15456, efix([1,5,4,5,6]), ...
                    emode, alatt, angdeg, u, v, psi([1,5,4,5,6]), omega([1,5,4,5,6]), ...
                    dpsi([1,5,4,5,6]), gl([1,5,4,5,6]), gs([1,5,4,5,6]));
                %'replicate'); ?
                ok=false;
            catch ME
                ok=true;
                assertEqual(ME.identifier,'GEN_SQW:invalid_argument')
                
            end
            %[fpath,fname]=fileparts(obj.spe_file{5});
            %delete(fullfile(fpath,[fname,'_2.tmp']));
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
