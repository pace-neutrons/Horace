classdef test_bm_func_eval_smallData < TestCase
    %TEST_BM_FUNC_EVAL_SMALLDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        func_1D = @slow_func;
        func_1D_params={[175,1,0.05],@gauss,10^0};
        func_2D = @slow_func;
        func_2D_params={[350,1,100,0.05,0.05,0.05],@gauss2d,10^0};
        func_3D = @slow_func;
        func_3D_params={[700,-1,2,500,0.05,0.05,0.04,0.05,0.05,0.05],...
            @gauss3d,10^0};
        func_4D = @slow_func;
        func_4D_params={[700,-1,2,1,500,0.05,0.05,0.05,0.05,0.05,0.05,0.05...
            ,0.05,0.05,0.05],@gauss4d,10^0};
        common_data;
        dataSize = 'small';
        dataSource;
    end
    
    methods

        function obj = test_bm_func_eval_smallData(test_class_name)
            %TEST_BM_FUNC_EVAL_SMALLDATA Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_smallData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData8.sqw');
        end

        function test_bm_func_eval_1D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

%         function test_bm_func_eval_4D_smallData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_4D_smallData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 1;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_4D_smallData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end

%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_func_eval_1D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end

%         function test_bm_func_eval_4D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_4D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_4D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
%         
%         function test_bm_func_eval_2D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
%
%         function test_bm_func_eval_4D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_4D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_4D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_4D,obj.func_4D_params,nProcs,obj.function_name);
%         end

    end
end

