classdef test_bm_combine_sqw_mediumData < TestCase
    %TEST_VM_COMBINE_SQW_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
                )),'common_data');
    end
    
    methods
        function obj = test_bm_combine_sqw_mediumData(test_class_name)
            %TEST_BM_COMBINE_SQW_MEDIUMDATA Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_combine_sqw_mediumData';
            end
            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_combine_sqw_1D_mediumData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'small';
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'medium';
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'large';
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_smallNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'small';
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_mediumNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'medium';
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_largeNumber_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'large';
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_smallNumber_2procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'small';
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_mediumNumber_2procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'medium';
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_largeNumber_2procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'large';
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_smallNumber_2procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'small';
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_mediumNumber_2procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'medium';
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_largeNumber_2procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'large';
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_smallNumber_4procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'small';
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_mediumNumber_4procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'medium';
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_largeNumber_4procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=1;
            dataType ='medium';
            dataNum = 'large';
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_smallNumber_4procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'small';
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_mediumNumber_4procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'medium';
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_largeNumber_4procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv";
            nDims=2;
            dataType ='medium';
            dataNum = 'large';
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataType,dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end
    end
end

