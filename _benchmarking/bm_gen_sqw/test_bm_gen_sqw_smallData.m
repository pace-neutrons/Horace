classdef test_bm_gen_sqw_smallData < TestCase
    %TEST_BM_GEN_SQW_SMALLDATA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        function_name;
        dataSize = 'small';
    end
    
    methods
        function obj = test_bm_gen_sqw_smallData(test_class_name)
            %TEST_BM_GEN_SQW_SMALLDATA Construct an instance of this class
            %   Detailed explanation goes here
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_gen_sqw_smallData';
            end
            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_gen_sqw_smallData_smallNumber_1procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'small';
%             par_file = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_mediumNumber_1procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'medium';
%             par_file = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_largeNumber_1procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'large';
%             par_file = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_smallNumber_2procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'small';
%             par_file = 'small';
            nProcs = 2;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_mediumNumber_2procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'medium';
%             par_file = 'small';
            nProcs = 2;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_largeNumber_2procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'large';
%             par_file = 'small';
            nProcs = 2;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_smallNumber_4procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'small';
%             par_file = 'small';
            nProcs = 4;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_mediumNumber_4procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'medium';
%             par_file = 'small';
            nProcs = 4;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end

        function test_bm_gen_sqw_smallData_largeNumber_4procs(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.function_name = get_bm_name();
            dataSet = 'large';
%             par_file = 'small';
            nProcs = 4;
            benchmark_gen_sqw(obj.dataSize,dataSet,nProcs,obj.function_name);%par_file
        end
    end
end

