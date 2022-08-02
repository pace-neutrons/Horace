classdef test_bm_combine_sqw_smallData < TestCase
    %TEST_BM_COMBINE_SQW_SMALLDATA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        function_name;
        common_data;
        dataSize = 'small';
        dataSource;
        
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
            obj.dataSource = fullfile(obj.common_data,'NumData6.sqw');
        end

        function test_bm_combine_sqw_1D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_smallData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_smallData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end
    end

end
