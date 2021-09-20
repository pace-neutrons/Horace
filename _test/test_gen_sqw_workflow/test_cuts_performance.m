classdef test_cuts_performance < SQW_GENCUT_perf_tester
    properties
        % how many test files to use to define the perfromance results
        n_test_files = 10;
        cleanup_config_holder
        skip_mex_tests = false;
    end
    methods
        function obj=test_cuts_performance(varargin)
            if nargin>0
                test_name = varargin{1};
            else
                test_name = 'test_cuts_performance';
            end
            the_test_loc = fileparts(mfilename('fullpath'));
            test_res_filename = fullfile(the_test_loc,'CUTS_PERF_PerfRez.xml');
            obj = obj@SQW_GENCUT_perf_tester(test_name,test_res_filename);
            % this switch, if True, disables generation of target sqw file
            % if the file already exists and the number of contributing files
            % is equal to the number of files provided in n_test_files.
            obj.build_sqw_file_directly = false;
            % this expression will generate test files and build sqw file
            obj.n_files_to_use = obj.n_test_files;
            
            [~,nerrors] = check_horace_mex();
            if nerrors> 0
                obj.skip_mex_tests = true;
            end
        end
        
        function setUp(obj)
            hc = hor_config;
            hcds = hc.get_data_to_store();
            hpc = hpc_config;
            hpcds = hpc.get_data_to_store();
            parc = parallel_config();
            parcds = parc.get_data_to_store();
            obj.cleanup_config_holder = struct('hor_config',hcds,'hpc_config',hpcds,...
                'parallel_config',parcds);
        end
        function tearDown(obj)
            set(hor_config,obj.cleanup_config_holder.hor_config);
            set(hpc_config,obj.cleanup_config_holder.hpc_config);
            set(parallel_config,obj.cleanup_config_holder.parallel_config);
        end
        
        function [perf_nm,perf_mex]=test_small_cut_mex_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = false;
            if hc.log_level >0
                disp('**** Testing test_small_cut no-mex performance')
            end
            
            names_map = obj.build_default_test_names(0,'nomex');
            [perf_nm,cut1n,cut2n,cut3n,cut4n] = obj.small_cut_task_performance(names_map);
            
            if obj.skip_mex_tests
                skipTest('test_small_cut_mex disabled as mex files are compiled with errors')
            else
                if hc.log_level >0
                    disp('**** Testing test_small_cut mex performance')
                end
            end
            
            hc.use_mex = true;
            names_map = obj.build_default_test_names(0,'mex');
            [perf_mex,cut1m,cut2m,cut3m,cut4m] = obj.small_cut_task_performance(names_map);
            
            assertEqualToTol(cut1n,cut1m,'tol',1.e-8);
            assertEqualToTol(cut2n,cut2m,'tol',1.e-8);
            assertEqualToTol(cut3n,cut3m,'tol',1.e-8);
            assertEqualToTol(cut4n,cut4m,'tol',1.e-8);
            
        end
        function [perf_nom,perf_mex]=test_large_cut_nopix_nomex_mex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = false;
            if hc.log_level >0
                disp('**** Testing test_large_cut_nopix no-mex performance')
            end
            
            
            names_map = obj.build_default_test_names(0,'nomex');
            [perf_nom,cut1n,cut2n,cut3n,cut4n] = obj.large_cut_nopix_task_performance(names_map);
            
            if obj.skip_mex_tests
                skipTest('test_small_cut_mex disabled as mex files are compiled with errors')
            else
                if hc.log_level >0
                    disp('**** Testing test_large_cut_nopix mex performance')
                end
                
            end
            
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'mex');
            [perf_mex,cut1m,cut2m,cut3m,cut4m] = obj.large_cut_nopix_task_performance(names_map);
            % this test does not work because of binning errors/ Physically
            % cuts are equivalent
            assertEqualToTol(cut1n,cut1m,'tol',1.e-5);
            assertEqualToTol(cut2n,cut2m,'tol',1.e-5);
            assertEqualToTol(cut3n,cut3m,'tol',1.e-5);
            assertEqualToTol(cut4n,cut4m,'tol',1.e-5);
            
        end
        function perf_res=test_large_cut_filebased_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = false;
            
            names_map = obj.build_default_test_names(0,'nomex');
            perf_res = obj.large_cut_pix_fbased_task_perfornance(names_map);
        end
        function perf_res=test_large_cut_filebased_mex(obj)
            if obj.skip_mex_tests
                skipTest('test_large_cut_filebased_mex disabled as mex files are compiled with errors')
            end
            
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'mex');
            perf_res = obj.large_cut_pix_fbased_task_perfornance(names_map);
        end
        
    end
end
