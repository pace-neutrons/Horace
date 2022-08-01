classdef test_bm_tobyfit_mediumData < TestCase
    %TEST_BM_TOBYFIT_MEDIUMDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        common_data = fullfile(fileparts(fileparts(mfilename('fullpath')...
            )),'common_data');
    end
    
    methods
        function obj = test_bm_tobyfit_mediumData(test_class_name)
            %TEST_BM_TOBYFIT_MEDIUMDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_tobyfit_smallData';
            end

            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_tobyfit_1D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end
    
        function test_bm_tobyfit_1D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end
 
        function test_bm_tobyfit_1D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=1;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_2D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=2;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_smallNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "small";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_mediumNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "medium";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

        function test_bm_tobyfit_3D_mediumData_largeNumber_1procs(obj)
            obj.function_name = get_bm_name();
            nDims=3;
            dataSource = fullfile(obj.common_data,'NumData7.sqw');
            dataType = "medium";
            dataNum = "large";
            nProcs = 1;
            sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
            benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
        end

%         function test_bm_tobyfit_1D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_smallNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_mediumNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_largeNumber_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 2;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_1D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%     
%         function test_bm_tobyfit_1D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
%  
%         function test_bm_tobyfit_1D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=1;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_2D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=2;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_smallNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "small";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_mediumNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "medium";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
% 
%         function test_bm_tobyfit_3D_mediumData_largeNumber_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims=3;
%             dataSource = fullfile(obj.common_data,'NumData7.sqw');
%             dataType = "medium";
%             dataNum = "large";
%             nProcs = 4;
%             sqw_obj = gen_bm_tobyfit_data(nDims,dataSource,dataType,dataNum);
%             benchmark_tobyfit(sqw_obj,nProcs,obj.function_name);
%         end
    end
end

