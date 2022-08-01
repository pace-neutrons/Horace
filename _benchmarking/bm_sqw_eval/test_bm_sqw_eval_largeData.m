classdef test_bm_sqw_eval_largeData <TestCase
    %TEST_BM_SQW_EVAL_LARGEDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        sqw_eval_func = @demo_FM_spinwaves;
        params = [250 0 2.4 10 5];
        common_data=fullfile(fileparts(fileparts(mfilename('fullpath')...
            )),'common_data');
    end
    
    methods
        function obj = test_bm_sqw_eval_largeData(test_class_name)
            %TEST_BM_SQW_EVAL_largeData Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_largeData';
            end
            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_sqw_eval_1D_sqw_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "small";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "medium";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "large";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "small";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "medium";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "large";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "small";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "medium";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "large";
            nProcs = 1;
            objType="sqw";
            sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_obj,obj.sqw_eval_func,obj.params...
                ,nProcs,obj.function_name);
        end

         function test_bm_sqw_eval_1D_dnd_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "small";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "medium";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "large";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "small";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "medium";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "large";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_largeData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "small";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs...
                ,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_largeData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "medium";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_largeData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData8.sqw');
            dataType = "large";
            dataNum = "large";
            nProcs = 1;
            objType="dnd";
            sqw_dnd_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
            benchmark_sqw_eval(sqw_dnd_obj,obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

%         function test_bm_sqw_eval_1D_sqw_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "small";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.gauss_1D_func,obj.gauss_1D_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "medium";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.gauss_1D_func,obj.gauss_1D_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "large";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.gauss_1D_func,obj.gauss_1D_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "small";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "medium";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "large";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_largeData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "small";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_largeData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "medium";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_largeData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "large";
%             nProcs = 2;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "small";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.gauss_1D_func,obj.gauss_1D_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "medium";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.gauss_1D_func,obj.gauss_1D_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "large";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.gauss_1D_func,obj.gauss_1D_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "small";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "medium";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "large";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_largeData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "small";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_largeData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "medium";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_largeData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData8.sqw');
%             dataType = "large";
%             dataNum = "large";
%             nProcs = 4;
%             objType="sqw";
%             sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataType,dataNum,objType);
%             benchmark_sqw_eval(sqw_obj,obj.sqw_func,obj.sqw_func_params...
%                 ,nProcs,obj.function_name);
%         end
    end
end

