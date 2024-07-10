classdef test_gen_sqw_accumulate_sqw_parpool <  ...
        gen_sqw_common_config & gen_sqw_accumulate_sqw_tests_common
    % Series of tests of gen_sqw and associated functions run on pool of
    % workers, provided by Matlab parallel computing toolbox.
    %
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
    %>>runtests test_gen_sqw_accumulate_sqw_parpool
    %---------------------------------------------------------------------
    %2) Run particular test case from the suite:
    %
    %>>tc = test_gen_sqw_accumulate_sqw_parpool();
    %>>tc.test_[particular_test_name] e.g.:
    %>>tc.test_accumulate_sqw14();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_gen_sqw_accumulate_sqw_sep_session('save');
    %>>tc.save():
    properties
        tc;
    end
    methods
        function obj=test_gen_sqw_accumulate_sqw_parpool(test_name,varargin)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with
            %   previously saved results in
            %   test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same
            %                                           folder as this
            %                                           function
            %   >> test_gen_sqw_accumulate_sqw ('save') % Save to
            %   test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.

            % constructor
            if ~exist('test_name','var')
                test_name = mfilename('class');
            end
            combine_algorithm = 'mpi_code'; % this is what should be tested
            %TODO: but on windows it is not optimized and is very slow, so:
            if ispc() % TODO: this should be fixed
                combine_algorithm  = 'mex_code';
            end

            obj = obj@gen_sqw_common_config(-1,1,combine_algorithm,'parpool');
            obj = obj@gen_sqw_accumulate_sqw_tests_common(test_name,'parpool');
            obj.print_running_tests = true;
            obj.tc = tic();
        end
        function delete(obj)
            disp('Total time to run gen_sqw_accumulate_sqw_parpool code:')
            toc(obj.tc);
        end
        function test_replicate_in_parallel_and_serially(obj,varargin)
            %-------------------------------------------------------------
            if obj.skip_test
                skipTest(fprintf('test_replicate_in_parallel_and_serially_%s is disabled',obj.test_pref));
            end
            if nargin> 1
                % running in single test method mode.
                obj.setUp();
                clobS = onCleanup(@()obj.tearDown());
            end
            %-------------------------------------------------------------
            clConf   = set_temporary_config_options('hor_config','delete_tmp',true);
            clParConf = set_temporary_config_options('parallel_config','parallel_workers_number',2);            

            wk_dir = obj.working_dir;

            sqw_file_parallel=fullfile(wk_dir,'test_sqw_replicate_parallel.sqw');
            sqw_file_serial  =fullfile(wk_dir,'test_sqw_replicate_serial.sqw');
            clSqw=onCleanup(@()del_memmapfile_files(sqw_file_parallel,sqw_file_serial));

            % --------------------------------------- Test accumulate_sqw
            % ---------------------------------------

            % Create some sqw files against which to compare the output of
            % accumulate_sqw
            % ---------------------------------------------------------------------------
            [~,efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs]=unpack(obj);
            spe = {obj.spe_file{1},obj.spe_file{1},obj.spe_file{4},obj.spe_file{4}};
            sel  = 1:4;

            [~,~,pix_range_ser]=gen_sqw (spe, '', sqw_file_parallel, efix(sel),...
                emode, alatt, angdeg, u, v, psi(sel), omega(sel), dpsi(sel), gl(sel), gs(sel), ...
                'replicate');

            % Now do this serially ----------------------
            parConfig = set_temporary_config_options('hpc_config','build_sqw_in_parallel',false);
            [~,~,pix_range_par]=gen_sqw (spe, '', sqw_file_serial, efix(sel),...
                emode, alatt, angdeg, u, v, psi(sel), omega(sel), dpsi(sel), gl(sel), gs(sel), ...
                'replicate');

            assertElementsAlmostEqual(pix_range_par,pix_range_ser);

            sq_par = sqw(sqw_file_parallel);
            sq_ser = sqw(sqw_file_serial);
            assertEqualToTol(sq_par,sq_ser,'ignore_str',true,'tol',[1.e-8,1.e-8]);
        end


        %------------------------------------------------------------------
        % Block of code to disable some tests for debugging Jenkins jobs
        function test_gen_sqw(obj,varargin)
            %             if is_jenkins && ispc
            %                 skipTest('Test disabled due to intermittent failure')
            %             end
            test_gen_sqw@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_accumulate_sqw14(obj,varargin)
            %             if is_jenkins && ispc
            %                 skipTest('Test disabled due to intermittent failure')
            %             end
            test_accumulate_sqw14@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_accumulate_and_combine1to4(obj,varargin)
            %             if is_jenkins && ispc
            %                 skipTest('Test disabled due to intermittent failure')
            %             end
            test_accumulate_and_combine1to4@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_accumulate_sqw1456(obj,varargin)
            %             if is_jenkins && ispc
            %                 skipTest('Test disabled due to intermittent failure')
            %             end
            test_accumulate_sqw1456@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
        function test_accumulate_sqw11456(obj,varargin)
            %             if is_jenkins && ispc
            %                 skipTest('Test disabled due to intermittent failure')
            %             end
            test_accumulate_sqw11456@gen_sqw_accumulate_sqw_tests_common(obj,varargin{:});
        end
    end

end
