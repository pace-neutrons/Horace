classdef test_bm_tobyfit_fit_largeData < TestCase
    %TEST_BM_TOBYFIT_FIT_LARGEDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        common_data;
        dataSize = 'large';
        dataSource;
    end
    
    methods
        function obj = test_bm_tobyfit_fit_largeData(test_class_name)
            %TEST_BM_tobyfit_fit_LARGEDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_tobyfit_fit_smallData';
            end

            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData8.sqw');
        end
        
        function test_bm_tobyfit_fit_1D_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
    
        function test_bm_tobyfit_fit_1D_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
 
        function test_bm_tobyfit_fit_1D_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
% 
%         function test_bm_tobyfit_fit_2D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end

% 
%         function test_bm_tobyfit_fit_2D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end

%         function test_bm_tobyfit_fit_4D_largeData_smallNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_4D_largeData_mediumNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_4D_largeData_largeNumber_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 1;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end



%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_tobyfit_fit_1D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_fit_1D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_fit_1D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end

%         function test_bm_tobyfit_fit_4D_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_4D_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_4D_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_1D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_fit_1D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_fit_1D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_2D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_3D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end

%         function test_bm_tobyfit_fit_4D_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_fit_4D_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = "medium";
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
% 
%         function test_bm_tobyfit_fit_4D_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=4;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit_fit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);        
%         end
    end
end

