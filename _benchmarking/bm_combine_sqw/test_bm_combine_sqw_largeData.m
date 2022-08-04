classdef test_bm_combine_sqw_largeData < TestCase
    %TEST_BM_COMBINE_SQW_LARGEDATA Summary of this class goes here
    %   Detailed explanation goes here
<<<<<<< HEAD
<<<<<<< HEAD

    properties
        function_name;
        common_data;
        dataSize = 'large';
        dataSource;
    end

=======
    
=======

>>>>>>> 7a8c2792b (Use horace_paths object)
    properties
        function_name;
        common_data;
    end
<<<<<<< HEAD
    
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======

>>>>>>> 7a8c2792b (Use horace_paths object)
    methods
        function obj = test_bm_combine_sqw_largeData(test_class_name)
            %TEST_BM_COMBINE_SQW_LARGEDATA Construct an instance of this class
            %   Detailed explanation goes here
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_combine_sqw_largeData';
            end
            obj = obj@TestCase(test_class_name);
<<<<<<< HEAD
<<<<<<< HEAD
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData6.sqw');
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_3D_largeData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,...
                obj.function_name);
        end
    end
end
=======
=======
            pths = horace_paths;
            obj.common_data = pths.bm_common;
<<<<<<< HEAD
>>>>>>> 7a8c2792b (Use horace_paths object)
=======
            obj.dataSource = fullfile(obj.common_data,'NumData6.sqw');
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'small';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'medium';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'large';
            nProcs = 1;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'small';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'medium';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_2procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'large';
            nProcs = 2;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_1D_largeData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataNum = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_smallNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'small';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_mediumNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'medium';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end

        function test_bm_combine_sqw_2D_largeData_largeNumber_4procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataNum = 'large';
            nProcs = 4;
            benchmark_combine_sqw(nDims,obj.dataSource,obj.dataSize,dataNum,nProcs,...
                obj.function_name);
        end
    end
end
<<<<<<< HEAD

>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
>>>>>>> 7a8c2792b (Use horace_paths object)
