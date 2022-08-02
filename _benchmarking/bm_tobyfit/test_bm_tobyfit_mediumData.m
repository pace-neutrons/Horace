classdef test_bm_tobyfit_mediumData < TestCase
    %TEST_BM_TOBYFIT_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
<<<<<<< HEAD
<<<<<<< HEAD
        common_data;
        dataSource;
        dataSize = 'medium';
=======
        common_data = fullfile(fileparts(fileparts(mfilename('fullpath')...
            )),'common_data');
>>>>>>> 7e6efa9a0 (adding tobyfit benchmarks)
=======
        common_data;
        dataSource;
        dataSize = 'medium';
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
    end
    
    methods
        function obj = test_bm_tobyfit_mediumData(test_class_name)
            %TEST_BM_TOBYFIT_MEDIUMDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_tobyfit_smallData';
            end

            obj = obj@TestCase(test_class_name);
<<<<<<< HEAD
<<<<<<< HEAD
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData7.sqw');
<<<<<<< HEAD
        end
        
        function test_bm_tobyfit_1D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
    
        function test_bm_tobyfit_1D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet ='medium';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
 
        function test_bm_tobyfit_1D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
        
%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_tobyfit_1D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;             
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;             
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_1D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;             
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
=======
=======
            pths = horace_paths;
            obj.common_data = pths.bm_common;
>>>>>>> 7a8c2792b (Use horace_paths object)
=======
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
        end
        
        function test_bm_tobyfit_1D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
    
        function test_bm_tobyfit_1D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet ='medium';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
 
        function test_bm_tobyfit_1D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
                nProcs,obj.function_name);
        end
        
%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_tobyfit_1D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;             
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;             
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_1D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;             
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
<<<<<<< HEAD
<<<<<<< HEAD
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
>>>>>>> 7e6efa9a0 (adding tobyfit benchmarks)
=======
%             benchmark_tobyfit(nDims,dataSource,dataType,dataNum,nProcs,obj.function_name);
>>>>>>> d26fc9d4c (getting rid of duplicate code)
=======
%             benchmark_tobyfit(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 nProcs,obj.function_name);
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
%         end
    end
end

