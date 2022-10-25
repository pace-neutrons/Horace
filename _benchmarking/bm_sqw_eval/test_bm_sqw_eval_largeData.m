classdef test_bm_sqw_eval_largeData <TestCase
%TEST_BM_SQW_EVAL_LARGEDATA largeData Benchmark class for sqw_eval()
% This set of benchmarks uses "large" sized sqw objects (10^9 pixels).
% The parameters that are varied in this set of benchmarks are:
%   - nDims: the dimensions of the sqw objects to combine: 1,2 or 3
%   - dataSet: the number of sqw objects in the array
%   - nProcs: the number of processors the benchmarks will run on
%   - objectType: sqw or dnd object

    properties
        function_name;
        sqw_eval_func=@slow_func;
        params = {[250 0 2.4 10 5],@demo_FM_spinwaves,10^0};
        common_data;
        dataSize = 'large';
    end

    methods
        function obj = test_bm_sqw_eval_largeData(test_class_name)
            %TEST_BM_SQW_EVAL_largeData Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_largeData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            addpath(pths.bm_common_func);
        end

% ocr96: Currently running into Out of Memory error in Anvil when running largeData test
% commented out untill appropriate data size is chosen or memory issue in
% Anvil resolved

%         function test_bm_sqw_eval_1D_sqw_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_sqw_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_sqw_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 1;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
% 4D tests commented out as they take very long to run, and needs to be
% determined if they are worth running: do they represent a true use case ?

% %         function test_bm_sqw_eval_4D_sqw_largeData_smallNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'small';
% %             nProcs = 1;
% %             objType="sqw";
% %             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
% %                 obj.sqw_eval_func,obj.params,nProcs);
% %         end
% %
% %         function test_bm_sqw_eval_4D_sqw_largeData_mediumNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'medium';
% %             nProcs = 1;
% %             objType="sqw";
% %             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
% %                 obj.sqw_eval_func,obj.params,nProcs);
% %         end
% %
% %         function test_bm_sqw_eval_4D_sqw_largeData_largeNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'large';
% %             nProcs = 1;
% %             objType="sqw";
% %             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
% %                 obj.sqw_eval_func,obj.params,nProcs);
% %         end

%          function test_bm_sqw_eval_1D_dnd_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_dnd_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_dnd_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 1;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end

% 4D tests commented out as they take very long to run, and needs to be
% determined if they are worth running: do they represent a true use case ?

% %         function test_bm_sqw_eval_4D_dnd_largeData_smallNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'small';
% %             nProcs = 1;
% %             objType="dnd";
% %             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
% %                 obj.sqw_eval_func,obj.params,nProcs);
% %         end
% %
% %         function test_bm_sqw_eval_4D_dnd_largeData_mediumNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'medium';
% %             nProcs = 1;
% %             objType="dnd";
% %             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
% %                 obj.sqw_eval_func,obj.params,nProcs);
% %         end
% %
% %         function test_bm_sqw_eval_4D_dnd_largeData_largeNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'large';
% %             nProcs = 1;
% %             objType="dnd";
% %             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
% %                 obj.sqw_eval_func,obj.params,nProcs);
% %         end

%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_sqw_eval_1D_sqw_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_sqw_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_sqw_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end

%         function test_bm_sqw_eval_4D_sqw_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_sqw_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_sqw_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%          function test_bm_sqw_eval_1D_dnd_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_dnd_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_dnd_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_dnd_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_dnd_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_dnd_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_sqw_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_sqw_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_sqw_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_sqw_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_sqw_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%          function test_bm_sqw_eval_4D_sqw_largeData_smallNumber_4procs(obj)
%                     obj.function_name = get_bm_name();
%                     nDims=4;
%                     dataSet = 'small';
%                     nProcs = 4;
%                     objType="sqw";
%                     benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                         obj.sqw_eval_func,obj.params,nProcs);
%          end
%
%          function test_bm_sqw_eval_4D_sqw_largeData_mediumNumber_4procs(obj)
%                     obj.function_name = get_bm_name();
%                     nDims=4;
%                     dataSet = 'medium';
%                     nProcs = 4;
%                     objType="sqw";
%                     benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                         obj.sqw_eval_func,obj.params,nProcs);
%          end
%
%          function test_bm_sqw_eval_4D_sqw_largeData_largeNumber_4procs(obj)
%                     obj.function_name = get_bm_name();
%                     nDims=4;
%                     dataSet = 'large';
%                     nProcs = 4;
%                     objType="sqw";
%                     benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                         obj.sqw_eval_func,obj.params,nProcs);
%          end
%
%          function test_bm_sqw_eval_1D_dnd_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_dnd_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_1D_dnd_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_2D_dnd_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_3D_dnd_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_dnd_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_dnd_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
%
%         function test_bm_sqw_eval_4D_dnd_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs);
%         end
    end
end
