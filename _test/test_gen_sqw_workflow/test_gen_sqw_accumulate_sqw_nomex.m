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
        function test_wrong_params_gen_sqw(obj,varargin)
            if nargin > 1  % running in single test method mode.
                obj.setUp();
                co1 = onCleanup(@()obj.tearDown());
                
            end
            % something wrong with this test -- it was with 'replicate'
            % option and apparently failing
            sqw_file_15456=fullfile(tmp_dir,['sqw_123456_',obj.test_pref,'.sqw']);  % output sqw file which should never be created
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            spe_files = obj.spe_file([1,5,4,5,6]);
                        
            try
                gen_sqw (spe_files, '', sqw_file_15456, efix([1,5,4,5,6]),...
                    emode, alatt, angdeg, u, v, psi([1,5,4,5,6]), omega([1,5,4,5,6]),...
                    dpsi([1,5,4,5,6]), gl([1,5,4,5,6]), gs([1,5,4,5,6]));
                ok=false;
            catch ME
                ok=true;
                assertEqual(ME.identifier,'GEN_SQW:invalid_argument')
                
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
                assertEqual(ME.identifier,'GEN_SQW:invalid_argument');
            end
            assertTrue(ok,'Should have failed because of repeated spe file name');            
        end
        function test_cut_with_uoffset(obj,varargin)
            %-------------------------------------------------------------
            if nargin> 1
                % running in single test method mode.
                obj.setUp();
                co1 = onCleanup(@()obj.tearDown());
            end
            %-------------------------------------------------------------
            
            
            % build test files if they have not been build
            obj=build_test_files(obj);
            % generate the names of the output sqw files
            
            sqw_file=cell(1,obj.nfiles_max);
            file_pref = obj.test_pref;
            wkdir = obj.working_dir;
            for i=1:obj.nfiles_max
                sqw_file{i}=fullfile(wkdir ,['test_gen_sqw_',file_pref ,num2str(i),'.sqw']);    % output sqw file
            end
            
            sqw_file_123456=fullfile(wkdir ,['sqw_123456_',file_pref,'.sqw']);                 % output sqw file
            if ~obj.save_output
                cleanup_obj1=onCleanup(@()obj.delete_files(sqw_file_123456,sqw_file{:}));
            end
            % ---------------------------------------
            % Test gen_sqw ---------------------------------------
            
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            %hc.threads = 1;
            
            
             gen_sqw (obj.spe_file, '', ...
                sqw_file_123456, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            % Make some cuts: ---------------
            proj = struct();
            proj.u=[1,0,0];
            proj.v=[0,1,0];
            
            
            w2 = cut_sqw(sqw_file_123456,proj,[-1.5,0.025,0],[-1.5,0.025,0],[-0.5,0.5],[10,30]);
            
            % Test against saved or store to save later
            obj.assertEqualToTolWithSave(w2,'ignore_str',true,'tol',1.e-7);
            
            
            w1a=cut_sqw(sqw_file_123456,obj.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            % Test against saved or store to save later
            obj.assertEqualToTolWithSave(w1a,'ignore_str',true,'tol',1.e-7);
        end
        
    end
end
