classdef test_bm_combine_sqw_largeData < TestCase
    %TEST_BM_COMBINE_SQW_LARGEDATA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        function_name;
        common_data;
    end

    methods
        function obj = test_bm_combine_sqw_largeData(test_class_name)
            %TEST_BM_COMBINE_SQW_LARGEDATA Construct an instance of this class
            %   Detailed explanation goes here
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_combine_sqw_largeData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'large';
            dataNum = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end
    end
end
