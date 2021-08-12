classdef test_cuts_performance < SQW_GENCUT_perf_tester
    properties
        % how many test files to use to define the perfromance results
        n_test_files = 5;
        cleanup_config
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
        
        function test_small_cut_perf_mex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            names_map = obj.build_default_test_names(0,'mex');
            pr = obj.small_cut_task_performance(names_map);
        end
        function test_large_cut_nopix_perf_mex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'mex');
            pr = obj.large_cut_nopix_task_performance(names_map);
        end
        function test_large_cut_filebased_perf_mex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'mex');
            pr = obj.large_cut_pix_fbased_task_perfornance(names_map);
        end
        function test_small_cut_perf_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            names_map = obj.build_default_test_names(0,'nomex');
            pr = obj.small_cut_task_performance(names_map);
        end
        function test_large_cut_nopix_perf_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'nomex');
            pr = obj.large_cut_nopix_task_performance(names_map);
        end
        function test_large_cut_filebased_perf_nomex(obj)
            hc = hor_config;
            hc.saveable = false;
            hc.use_mex = true;
            
            names_map = obj.build_default_test_names(0,'nomex');
            pr = obj.large_cut_pix_fbased_task_perfornance(names_map);
        end
    end
end
