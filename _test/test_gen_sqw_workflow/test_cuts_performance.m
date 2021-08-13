classdef test_cuts_performance < SQW_GENCUT_perf_tester
    properties
        % how many test files to use to define the perfromance results
        n_test_files = 50;
        cleanup_config
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
            
            obj.build_test_sqw_file = true;
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
            obj.cleanup_config = struct('hor_config',hcds,'hpc_config',hpcds,...
                'parallel_config',parcds);
        end
        function tearDown(obj)
            set(hor_config,obj.cleanup_config.hor_config);
            set(hpc_config,obj.cleanup_config.hpc_config);
            set(parallel_config,obj.cleanup_config.parallel_config);
        end
        
        function test_small_cut_mex_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = false;
            names_map = obj.build_default_test_names(0,'nomex');
            [pr_nm,cut1n,cut2n,cut3n,cut4n] = obj.small_cut_task_performance(names_map);
            
            if obj.skip_mex_tests
                skipTest('test_small_cut_mex disabled as mex files are compiled with errors')
            end
            
            hc.use_mex = true;
            names_map = obj.build_default_test_names(0,'mex');
            [pr_m,cut1m,cut2m,cut3m,cut4m] = obj.small_cut_task_performance(names_map);
            
            assertEqual(cut1n,cut1m);
            assertEqual(cut2n,cut2m);
            assertEqual(cut3n,cut3m);
            assertEqual(cut4n,cut4m);
            
        end
        function test_large_cut_nopix_perf_mex(obj)
            if obj.skip_mex_tests
                skipTest('test_small_cut_mex disabled as mex files are compiled with errors')
            end
            
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'mex');
            pr = obj.large_cut_nopix_task_performance(names_map);
        end
        function test_large_cut_filebased_mex(obj)
            if obj.skip_mex_tests
                skipTest('test_small_cut_mex disabled as mex files are compiled with errors')
            end
            
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'mex');
            pr = obj.large_cut_pix_fbased_task_perfornance(names_map);
        end
        function test_large_cut_nopix_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = false;
            
            names_map = obj.build_default_test_names(0,'nomex');
            pr = obj.large_cut_nopix_task_performance(names_map);
        end
        function test_large_cut_filebased_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = false;
            
            names_map = obj.build_default_test_names(0,'nomex');
            pr = obj.large_cut_pix_fbased_task_perfornance(names_map);
        end
    end
end
