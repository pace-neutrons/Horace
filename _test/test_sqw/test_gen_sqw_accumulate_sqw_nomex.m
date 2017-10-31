classdef test_gen_sqw_accumulate_sqw_nomex < test_gen_sqw_accumulate_sqw_mex
    % Series of tests of gen_sqw and associated functions
    % when mex code is disabled or not availible
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
        function this=test_gen_sqw_accumulate_sqw_nomex(varargin)
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
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@test_gen_sqw_accumulate_sqw_mex(name,'nomex');
            
        end
        
        
        function this=test_gen_sqw_threading_mex(this)
            % check 1 vs 8 threads mex and compare to one cut
            % shortest code to debug in case of errors
            %-------------------------------------------------------------
            [~,n_errors]=check_horace_mex();
            if n_errors>0
                return % if no mex enabled, this tests nothing
            end
            hc = hor_config;
            cur_mex = hc.use_mex;
            
            acsp=hc.accum_in_separate_process;
            umc= hc.use_mex_for_combine;
            nthr = hc.threads;
            %
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,...
                'accum_in_separate_process',acsp,'use_mex_for_combine',umc,...
                'threads',nthr));
            
            
            hc.use_mex=true;
            hc.accum_in_separate_process=false;
            hc.threads = 8;
            %-------------------------------------------------------------
            spe_file_names = cell(1,1);
            for i=1:1
                spe_file_names{i}=fullfile(tempdir,['test_gen_sqw_threading_1th',num2str(i),'.nxspe']);
            end
            
            
            sqw_file_123_t8=fullfile(tempdir,'sqw_123_mex8_threading.sqw');             % output sqw file
            sqw_file_123_t1=fullfile(tempdir,'sqw_123_mex1_threading.sqw');        % output sqw file
            cleanup_obj1=onCleanup(@()rm_files(this,sqw_file_123_t8,sqw_file_123_t1));
            % ---------------------------------------
            % Test gen_sqw
            % ---------------------------------------
            [en,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(this,numel(spe_file_names));
            % Make some cuts:
            % ---------------
            this.proj.u=[1,0,0.1]; this.proj.v=[0,0,1];
            hc.threads = 8;
            gen_sqw (spe_file_names, '', sqw_file_123_t8, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);
            
            
            
            % build test files if they have not been build
            %this=build_test_files(this,true,spe1_file_names);
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
            
            [ok,mess]=is_cut_equal(sqw_file_123_t8,sqw_file_123_t1,this.proj,[-1.5,0.025,0],[-2.1,-1.9],[-0.5,0.5],[-Inf,Inf]);
            assertTrue(ok,[' MEX threaded and non-threaded versions of gen_sqw are different: ',mess]);
            
            w_8 = d4d(sqw_file_123_t8);
            w_1 = d4d(sqw_file_123_t1);
            [ok,mess]=equal_to_tol(w_8,w_1,-1.e-8,'ignore_str',true);
            assertTrue(ok,[' MEX threaded and non-threaded versions of gen_sqw are different: ',mess]);
            
        end
        
        
    end
end
