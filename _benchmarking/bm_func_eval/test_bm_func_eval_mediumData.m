classdef test_bm_func_eval_mediumData < TestCase
    %TEST_BM_FUNC_EVAL_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        func_1D = @slow_func1d
        func_1D_params={[175,1,0.05],@gauss,10^0};
        func_2D = @slow_func2d
        func_2D_params={[350,1,100,0.05,0.05,0.05],@gauss2d,10^0};
        func_3D = @slow_func3d
        func_3D_params={[700,-1,2,500,0.05,0.05,0.04,0.05,0.05,0.05],...
            @gauss3d,10^0};
        common_data;
        
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
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_func_eval_1D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
%         
%         function test_bm_func_eval_2D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end

    end
end