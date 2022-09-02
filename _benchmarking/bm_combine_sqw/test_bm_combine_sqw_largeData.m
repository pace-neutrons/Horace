classdef test_bm_combine_sqw_largeData < TestCase
    %TEST_BM_COMBINE_SQW_LARGEDATA largeData Benchmark class for combine_sqw()
% This set of benchmarks uses "large" sized sqw objects created using 
% dummy_sqw (10^9 pixels) and then cut into 1,2, or 3D objects using 
% cut_sqw().
% The parameters that are varied in this set of benchmarks are:
%   - nDims: the dimensions of the sqw objects to combine: 1,2 or 3
%   - dataSet: the amount of sqw objects to combine:
%     Char: 'small', 'medium' or 'large' (2, 4 or 8) or an integer amount 
%       of objects
%   - nProcs: the number of processors the benchmarks will run on
    properties
        function_name;
        common_data;
        dataSize = 'large';
    end

    methods
        function obj = test_bm_combine_sqw_largeData(test_class_name)
            %TEST_BM_COMBINE_SQW_LARGEDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_combine_sqw_largeData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
        end
% ocr96: Currently running into Out of Memory error in Anvil when running largeData test
% commented out untill appropriate data size is chosen or memory issue in
% Anvil resolved

%
%         function test_bm_combine_sqw_1D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_1D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_1D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end

%% Below functions are for when cut_sqw is parallelised: using 2 and 4 processors

%         function test_bm_combine_sqw_1D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_1D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_1D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_1D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_1D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_1D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_2D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
% 
%         function test_bm_combine_sqw_3D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_combine_sqw(nDims,obj.dataSize,dataSet,nProcs,...
%                 obj.function_name);
%         end
    end

end