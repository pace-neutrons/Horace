classdef test_bm_func_eval_smallData < TestCase
    %TEST_BM_FUNC_EVAL_SMALLDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
<<<<<<< HEAD
<<<<<<< HEAD
        func_1D = @slow_func1d
        func_1D_params={[175,1,0.05],@gauss,10^0};
        func_2D = @slow_func2d
        func_2D_params={[350,1,100,0.05,0.05,0.05],@gauss2d,10^0};
        func_3D = @slow_func3d
        func_3D_params={[700,-1,2,500,0.05,0.05,0.04,0.05,0.05,0.05],...
            @gauss3d,10^0};
<<<<<<< HEAD
<<<<<<< HEAD
        common_data;
        dataSize = 'small';
        dataSource;
<<<<<<< HEAD
=======
%         gauss_1D_func=@gauss;
%         gauss_1D_params=[175,1,0.05];
%         %            p = [height, x1, stdev]
%         gauss_2D=@gauss2d;
%         gauss_2D_params=[350,1,100,0.05,0.05,0.05];
%         %           p = [height, x1_0, x2_0, c11, c12, c22,]
%         gauss_3D=@gauss3d;
%         gauss_3D_params=[700,-1,2,500,0.05,0.05,0.04,0.05,0.05,0.05];
% %                  p = [height, x1_0, x2_0, x3_0, c11, c12, c13, c22, c23, c33]
=======
>>>>>>> e70c887a5 (use of string instead of char)
        func_1D = @slow_func1d
        func_1D_params={[175,1,0.05],@gauss,10^0};
        func_2D = @slow_func2d
        func_2D_params={[350,1,100,0.05,0.05,0.05],@gauss2d,10^0};
        func_3D = @slow_func3d
        func_3D_params={[700,-1,2,500,0.05,0.05,0.04,0.05,0.05,0.05],...
<<<<<<< HEAD
            @gauss3d,1};
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
            @gauss3d,10^0};
>>>>>>> 3e222a29a (adding folder and fixing typos)
=======
        common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
            )),'common_data');
>>>>>>> f19dcce9c (switch to using dummy_sqw to generate bm data)
=======
        common_data;
>>>>>>> 7a8c2792b (Use horace_paths object)
=======
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
        
    end
    
    methods

        function obj = test_bm_func_eval_smallData(test_class_name)
            %TEST_BM_FUNC_EVAL_SMALLDATA Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_smallData';
            end
            obj = obj@TestCase(test_class_name);
<<<<<<< HEAD
<<<<<<< HEAD
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData8.sqw');
        end
        
        function test_bm_func_eval_1D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_func_eval_1D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
%         
%         function test_bm_func_eval_2D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
=======
=======
            pths = horace_paths;
            obj.common_data = pths.bm_common;
<<<<<<< HEAD
>>>>>>> 7a8c2792b (Use horace_paths object)
=======
            obj.dataSource = fullfile(obj.common_data,'NumData8.sqw');
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
        end
        
        function test_bm_func_eval_1D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_1D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_2D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'small';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'medium';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

        function test_bm_func_eval_3D_smallData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSet = 'large';
            nProcs = 1;
            benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
                obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
        end

%% The following benchmarks are for multi-processor/parallel-enabled codes
%         function test_bm_func_eval_1D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 2;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_1D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_1D,obj.func_1D_params,nProcs,obj.function_name);
%         end
%         
%         function test_bm_func_eval_2D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_2D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSet = 'large';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_2D,obj.func_2D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'small';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'medium';
%             nProcs = 4;
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_func_eval_3D_smallData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSet = 'large';
%             nProcs = 4;
<<<<<<< HEAD
<<<<<<< HEAD
%             sqw_obj = gen_bm_func_eval_data(nDims,dataSource,dataType,dataNum);
%             benchmark_func_eval(sqw_obj,obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
%             benchmark_func_eval(nDims,dataSource,dataType,dataNum,...
=======
%             benchmark_func_eval(nDims,obj.dataSource,obj.dataSize,dataSet,...
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
%                 obj.func_3D,obj.func_3D_params,nProcs,obj.function_name);
>>>>>>> 8d4db5de5 (updating gen_data functions)
%         end

    end
end

