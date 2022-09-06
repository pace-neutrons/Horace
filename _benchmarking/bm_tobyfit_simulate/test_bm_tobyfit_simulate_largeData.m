classdef test_bm_tobyfit_simulate_largeData < TestCase
%TEST_BM_TOBYFIT_SIMULATE_LARGEDATA largeData benchmark class for
% simulate().
% This set of benchmarks uses "large" sized sqw objects (10^9 pixels).
% The parameters that are varied in this set of benchmarks are:
%   - nDims: the dimensions of the sqw objects to combine: 1,2 or 3
%   - dataSet: the number of sqw objects in the array
%   - nProcs: the number of processors the benchmarks will run on

    properties
        function_name;
        common_data;
        dataSize = 'large';
        func_handle = @slow_func;
        params = {[250 0 2.4 10 5],@demo_FM_spinwaves,10^0};
    end

    methods
        function obj = test_bm_tobyfit_simulate_largeData(test_class_name)
            %TEST_BM_TOBYFIT_SIMULATE_LARGEDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_tobyfit_largeData';
            end

            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            addpath(pths.bm_common_func);
        end

% ocr96: Currently running into Out of Memory error in Anvil when running largeData test
% commented out untill appropriate data size is chosen or memory issue in
% Anvil resolved

%         function test_bm_tobyfit_simulate_1D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_1D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_1D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%
%         function test_bm_tobyfit_simulate_2D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
% % 4D tests commented out as they take very long to run, and needs to be
% % determined if they are worth running: do they represent a true use case ?
%
% %         function test_bm_tobyfit_simulate_4D_largeData_smallNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'small';
% %             nProcs = 1;
% %             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
% %                 nProcs,obj.func_handle,obj.params);
% %         end
% %
% %         function test_bm_tobyfit_simulate_4D_largeData_mediumNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = "medium";
% %             nProcs = 1;
% %             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
% %                 nProcs,obj.func_handle,obj.params);
% %         end
% %
% %         function test_bm_tobyfit_simulate_4D_largeData_largeNumber_1procs(obj)
% %             obj.function_name = get_bm_name();
% %             nDims=4;
% %             dataSet = 'large';
% %             nProcs = 1;
% %             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
% %                 nProcs,obj.func_handle,obj.params);
% %         end

%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_tobyfit_simulate_1D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_1D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_1D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end

%         function test_bm_tobyfit_simulate_4D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_4D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_4D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_1D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_1D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_1D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_2D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_3D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end

%         function test_bm_tobyfit_simulate_4D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_4D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
%
%         function test_bm_tobyfit_simulate_4D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_simulate(nDims,obj.dataSize,dataSet,...
%                 nProcs,obj.func_handle,obj.params);
%         end
    end
end

