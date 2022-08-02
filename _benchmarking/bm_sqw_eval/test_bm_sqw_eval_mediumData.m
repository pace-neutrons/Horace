classdef test_bm_sqw_eval_mediumData < TestCase
    %TEST_BM_SQW_EVAL_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here
<<<<<<< HEAD
<<<<<<< HEAD

=======
    
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======

>>>>>>> 89ccf4ee9 (Replace duplicated code (#833))
    properties
        function_name;
        sqw_eval_func=@demo_FM_spinwaves
        params = [250 0 2.4 10 5];
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        common_data;
        dataSize = 'medium';
        dataSource;
    end

=======
=======
        common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
            )),'common_data');
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
=======
        common_data;
<<<<<<< HEAD
>>>>>>> 7a8c2792b (Use horace_paths object)
=======
        dataSize = 'medium';
        dataSource;
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
    end
<<<<<<< HEAD
    
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======

>>>>>>> 89ccf4ee9 (Replace duplicated code (#833))
    methods
        function obj = test_bm_sqw_eval_mediumData(test_class_name)
            %TEST_BM_SQW_EVAL_mediumData Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_mediumData';
            end
            obj = obj@TestCase(test_class_name);
<<<<<<< HEAD
<<<<<<< HEAD
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData7.sqw');
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end
        
%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%           function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end

    end
end
=======
=======
            pths = horace_paths;
            obj.common_data = pths.bm_common;
<<<<<<< HEAD
>>>>>>> 7a8c2792b (Use horace_paths object)
=======
            obj.dataSource = fullfile(obj.common_data,'NumData7.sqw');
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end
        
%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%           function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,obj.dataSource,obj.dataSize,dataSet,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end

    end
end
<<<<<<< HEAD

>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
>>>>>>> 89ccf4ee9 (Replace duplicated code (#833))
