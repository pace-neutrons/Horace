classdef test_bm_sqw_eval_mediumData < TestCase
    %TEST_BM_SQW_EVAL_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here

    properties
        function_name;
        sqw_eval_func=@demo_FM_spinwaves
        params = [250 0 2.4 10 5];
        common_data;
    end

    methods
        function obj = test_bm_sqw_eval_mediumData(test_class_name)
            %TEST_BM_SQW_EVAL_mediumData Construct an instance of this class
             if ~exist('test_class_name','var')
                test_class_name = 'test_bm_sqw_eval_mediumData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            objType="sqw";
            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            objType="sqw";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            objType="sqw";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            objType="sqw";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            objType="sqw";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            objType="sqw";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            objType="sqw";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            objType="sqw";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            objType="dnd";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            objType="dnd";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            objType="dnd";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            objType="dnd";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'small';
            nProcs = 1;
            objType="dnd";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'medium';
            nProcs = 1;
            objType="dnd";

            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

        function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = 'medium';
            dataNum = 'large';
            nProcs = 1;
            objType="dnd";
            benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
                obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
        end

%         function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%           function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%               function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 2;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 2;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 2;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             objType="sqw";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_sqw_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             objType="sqw";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_1D_dnd_mediumData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%               function test_bm_sqw_eval_2D_dnd_mediumData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_2D_dnd_mediumData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%               function test_bm_sqw_eval_3D_dnd_mediumData_smallNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'small';
%             nProcs = 4;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_mediumNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'medium';
%             nProcs = 4;
%             objType="dnd";
% 
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end
% 
%         function test_bm_sqw_eval_3D_dnd_mediumData_largeNumber_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv";
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = 'medium';
%             dataNum = 'large';
%             nProcs = 4;
%             objType="dnd";
%             benchmark_sqw_eval(nDims,dataSource,dataType,dataNum,objType,...
%                 obj.sqw_eval_func,obj.params,nProcs,obj.function_name);
%         end

    end
end
