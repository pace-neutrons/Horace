classdef test_bm_tobyfit_fit_mediumData < TestCase
    %TEST_BM_TOBYFIT_FIT_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        common_data;
        dataSource;
        func_handle = @slow_func;
        params = {[6000, 0.2],@testfunc_nb_sqw,10}
        dataSize = 'medium';
    end
    
    methods
        function obj = test_bm_tobyfit_fit_mediumData(test_class_name)
            %TEST_BM_TOBYFIT_FIT_MEDIUMDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_tobyfit_fit_mediumData';
            end

            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData7.sqw');
        end
        
        function test_bm_tobyfit_fit_1D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);
        end
    
        function test_bm_tobyfit_fit_1D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);
        end
 
        function test_bm_tobyfit_fit_1D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);
        end

        function test_bm_tobyfit_fit_2D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);
        end


        function test_bm_tobyfit_fit_2D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = "medium";
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);
        end

        function test_bm_tobyfit_fit_2D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);        
        end

        function test_bm_tobyfit_fit_3D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);        
        end

        function test_bm_tobyfit_fit_3D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = "medium";
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);        
        end

        function test_bm_tobyfit_fit_3D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.func_handle,obj.params,obj.function_name);        
        end

%         function test_bm_tobyfit_fit_4D_mediumData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_4D_mediumData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_4D_mediumData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);        
%         end

%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_tobyfit_fit_1D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_fit_1D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_fit_1D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end

%         function test_bm_tobyfit_fit_4D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_4D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_4D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_1D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_fit_1D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_fit_1D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end

%         function test_bm_tobyfit_fit_4D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_4D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_4D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params,obj.function_name);        
%         end
    end
end

