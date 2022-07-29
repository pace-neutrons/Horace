classdef test_bm_sqw_eval_smallData <TestCase
    %TEST_BM_SQW_EVAL_SMALLDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        sqw_eval_func=@demo_FM_spinwaves
        params = [250 0 2.4 10 5];
        common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
            )),'common_data');
    end
    
    methods
        function obj = test_bm_sqw_eval_smallData(test_class_name)
            %TEST_BM_SQW_EVAL_SMALLDATA Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_smallData';
            end
            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_sqw_eval_1D_sqw_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            objType="sqw";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

         function test_bm_sqw_eval_1D_dnd_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

%         function test_bm_sqw_eval_1D_sqw_smallData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_smallData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_smallData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_smallData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_smallData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_smallData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_smallData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_smallData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_smallData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 2;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_smallData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_smallData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_smallData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_smallData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_smallData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_smallData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_smallData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_smallData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_smallData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 4;
%             objType="sqw";
%             sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
    end
end

