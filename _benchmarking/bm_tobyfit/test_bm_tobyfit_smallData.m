classdef test_bm_tobyfit_smallData < TestCase
    %TEST_BM_TOBYFIT_SMALLDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        common_data = fullfile(fileparts(fileparts(mfilename('fullpath')...
            )),'common_data');
    end
    
    methods

        function obj = test_bm_tobyfit_smallData(test_class_name)
            %TEST_BM_TOBYFIT_SMALLDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_tobyfit_smallData';
            end

            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_tobyfit_1D_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end
    
        function test_bm_tobyfit_1D_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end
 
        function test_bm_tobyfit_1D_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_smallData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_smallData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_smallData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = "small";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

%         function test_bm_tobyfit_1D_smallData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_smallData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_smallData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_smallData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_smallData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_smallData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_smallData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_smallData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_smallData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_1D_smallData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_smallData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_smallData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_smallData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_smallData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_smallData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_smallData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_smallData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_smallData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
%             dataType = "small";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end

    end
end

