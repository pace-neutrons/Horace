classdef test_bm_func_eval_mediumData < TestCase
%TEST_BM_FUNC_EVAL_MEDIUMDATA mediumData Benchmark class for func_eval()
% This set of benchmarks uses "medium" sized sqw objects (10^8 pixels).
% The parameters that are varied in this set of benchmarks are:
%   - nDims: the dimensions of the sqw objects to combine: 1,2 or 3
%   - dataSet: the number of sqw objects in the array
%   - nProcs: the number of processors the benchmarks will run on
%   - func_handle: the function used with func_eval(), will deend on
%     whether the sqw objects are 1,2,3 or 4 dimensional
    
    properties
        function_name;
        func_handle = @slow_func;
        func_1D_params={[175,1,0.05],@gauss,10^-1};
        func_2D_params={[350,1,100,0.05,0.05,0.05],@gauss2d,10^-1};
        func_3D_params={[700,-1,2,500,0.05,0.05,0.04,0.05,0.05,0.05],...
            @gauss3d,10^-1};
        func_4D_params={[700,-1,2,1,500,0.05,0.05,0.05,0.05,0.05,0.05,0.05...
            ,0.05,0.05,0.05],@gauss4d,10^-1};
        common_data;
        dataSize = 'medium';
    end
    
    methods

        function obj = test_bm_func_eval_mediumData(test_class_name)
            %TEST_BM_SQW_EVAL_mediumData Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_mediumData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
        end
               
        function test_bm_func_eval_1D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_1D_params,nProcs);
        end

        function test_bm_func_eval_1D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_1D_params,nProcs);
        end

        function test_bm_func_eval_1D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_1D_params,nProcs);
        end

        function test_bm_func_eval_2D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_2D_params,nProcs);
        end

        function test_bm_func_eval_2D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_2D_params,nProcs);
        end

        function test_bm_func_eval_2D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_2D_params,nProcs);
        end

        function test_bm_func_eval_3D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_3D_params,nProcs);
        end

        function test_bm_func_eval_3D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_3D_params,nProcs);
        end

        function test_bm_func_eval_3D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSize,dataSet,...
                obj.func_handle,obj.func_3D_params,nProcs);
        end
% 4D tests commented out as they take very long to run, and needs to be
% determined if they are worth running: do they represent a true use case ?


%         function test_bm_func_eval_4D_mediumData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 1;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end

%% The following benchmarks are for multi-processor/parallel-enabled codes

%         function test_bm_func_eval_1D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_1D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_1D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_1D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_2D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_2D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_2D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_3D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_3D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_3D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_1D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_1D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_1D_params,nProcs);
%         end
%         
%         function test_bm_func_eval_2D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_2D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_2D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_2D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_3D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_3D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_3D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end
% 
%         function test_bm_func_eval_4D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSize,dataSet,...
%                 obj.func_handle,obj.func_4D_params,nProcs);
%         end

    end
end
