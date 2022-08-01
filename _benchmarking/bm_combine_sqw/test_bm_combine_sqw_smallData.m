classdef test_bm_combine_sqw_smallData < TestCase
    %TEST_BM_CUT_SQW_SMALLDATA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        function_name;
        common_data;
    end

    methods
        function obj = test_bm_combine_sqw_smallData(test_class_name)
            %TEST_BM_COMBINE_SQW_SMALLDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_combine_sqw_smallData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
        end

        function test_bm_combine_sqw_1D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "small";
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "medium";
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "large";
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "small";
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "medium";
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "large";
            nProcs = 1;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "small";
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "medium";
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "large";
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "small";
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "medium";
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "large";
            nProcs = 2;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "small";
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "medium";
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "large";
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "small";
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "medium";
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType ="small";
            dataNum = "large";
            nProcs = 4;
            [cut1,cutN] = gen_bm_combine_data(nDims,dataSource, dataType, dataNum);
            benchmark_combine_sqw(cut1,cutN,nProcs,obj.function_name);
        end
    end

end
