classdef test_bm_combine_sqw_mediumData < TestCase
    %TEST_VM_COMBINE_SQW_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        function_name;
        common_data;
    end

    methods
        function obj = test_bm_combine_sqw_mediumData(test_class_name)
            %TEST_BM_COMBINE_SQW_MEDIUMDATA Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_combine_sqw_mediumData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
        end

        function test_bm_combine_sqw_1D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_mediumData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_mediumData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData6.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,dataSource,dataType,dataNum,nProcs,...
                obj.function_name);
        end
    end
end
