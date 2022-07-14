classdef test_bm_func_eval_mediumData < TestCase
    %TEST_BM_FUNC_EVAL_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        func_1D = @slow_func1d
        func_1D_params={[175,1,0.05],@gauss,20};
        func_2D = @slow_func2d
        func_2D_params={[350,1,100,0.05,0.05,0.05],@gauss2d,20};
        func_3D = @slow_func3d
        func_3D_params={[700,-1,2,500,0.05,0.05,0.04,0.05,0.05,0.05],...
            @gauss3d,20};
        
    end
    
    methods

        function obj = test_bm_func_eval_mediumData(test_class_name)
            %TEST_BM_SQW_EVAL_mediumData Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_mediumData';
            end
            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_func_eval_1D_mediumData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType = "medium";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_mediumData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType = "medium";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_mediumData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType = "medium";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_mediumData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType = "medium";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_mediumData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType = "medium";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_mediumData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType = "medium";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_mediumData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataType = "medium";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_mediumData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataType = "medium";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_mediumData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataType = "medium";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
            benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

%         function test_bm_func_eval_1D_mediumData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end

%         function test_bm_func_eval_3D_mediumData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_mediumData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
%         
%         function test_bm_func_eval_2D_mediumData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_mediumData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_mediumData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_func_eval_data(nDims,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end

    end
end