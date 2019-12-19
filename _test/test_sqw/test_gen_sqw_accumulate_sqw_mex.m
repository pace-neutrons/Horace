classdef test_gen_sqw_accumulate_sqw_mex < ...
        gen_sqw_accumulate_sqw_tests_common & gen_sqw_common_config
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
           
            obj = obj@gen_sqw_common_config(1,0,'mex_code',-1);            
            obj = obj@gen_sqw_accumulate_sqw_tests_common(name,'mex');            
        end
        %------------------------------------------------------------------
        % the test specific to mex mode
        function obj=test_gen_sqw_threading_mex(obj,varargin)
            % check 1 vs 8 threads mex and compare to one cut
            % shortest code to debug in case of errors
            %-------------------------------------------------------------
            if obj.skip_test
                return
            end
            if nargin> 1
                % running in single test method mode.
                obj.setUp();
                clob1 = onCleanup(@()obj.tearDown());
            end
            
            
            hc = hor_config;
            hc2save = hc.get_data_to_store();
            clob2 = onCleanup(@()set(hc,hc2save));
            hc.use_mex=true;
            hc.threads = 8;
            
            
            %-------------------------------------------------------------
            spe_file_names = cell(1,1);
            for i=1:1
                spe_file_names{i}=fullfile(tmp_dir,['test_gen_sqw_threading_1th',num2str(i),'.nxspe']);
            end
            % build special test files if they have not been build
            obj=build_test_files(obj,spe_file_names);
            
            
            sqw_file_123_t8=fullfile(tmp_dir,'sqw_123_mex8_threading.sqw');             % output sqw file
            sqw_file_123_t1=fullfile(tmp_dir,'sqw_123_mex1_threading.sqw');        % output sqw file
            clob3=onCleanup(@()obj.delete_files(sqw_file_123_t8,sqw_file_123_t1,spe_file_names{:}));
            % ---------------------------------------
            % Test gen_sqw
            % ---------------------------------------
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj,numel(spe_file_names));
            % Make some cuts:
            % ---------------
            obj.proj.u=[1,0,0.1]; obj.proj.v=[0,0,1];
            hc.threads = 8;
            gen_sqw (spe_file_names, '', sqw_file_123_t8, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            
            
            hc.threads = 1;
            gen_sqw (spe_file_names, '', sqw_file_123_t1, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            %
            % Test results
            obj_m8=read_sqw(sqw_file_123_t8);
            obj_m1=read_sqw(sqw_file_123_t1);
            %
            pix = sortrows(obj_m8.data.pix')';
            pix1 = sortrows(obj_m1.data.pix')';
            assertEqual(pix,pix1);
            assertEqual(obj_m8.data.s,obj_m1.data.s);
            assertEqual(obj_m8.data.e,obj_m1.data.e);
            assertEqual(obj_m8.data.npix,obj_m1.data.npix);
            
            [ok,mess]=is_cut_equal(sqw_file_123_t8,sqw_file_123_t1,obj.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,[' MEX threaded and non-threaded versions of gen_sqw are different: ',mess]);
            
            w_8 = d4d(sqw_file_123_t8);
            w_1 = d4d(sqw_file_123_t1);
            [ok,mess]=equal_to_tol(w_8,w_1,-1.e-8,'ignore_str',true);
            assertTrue(ok,[' MEX threaded and non-threaded versions of gen_sqw are different: ',mess]);
            
        end
        
        
    end
end
