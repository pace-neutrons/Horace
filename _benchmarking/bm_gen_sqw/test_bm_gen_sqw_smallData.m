classdef test_bm_gen_sqw_smallData < TestCase
% TEST_BM_GEN_SQW_SMALLDATA smallData Benchmark class for gen_sqw()
% This set of benchmarks uses "small" sized nxspe files to generate 
% sqw objects.The nxspe files are created using dummy_spe, with Energy 
% bin boundaries of 0:16:787 (smallData).
% The parameters that are varied in this set of benchmarks are:
%   - dataSet: the amount of nxspe files used to generate an sqw obj.
%     Char: 'small', 'medium' or 'large' (12, 23 and 46 files 
%     respectively) or an integer amount of files.
%   - detectorSize: the amount of detectors used to generate a
%     the needed par_file info. 'small', 'medium' or 'large'.
%     Corresponding to MAPS, MERLIN and LET. 
%   - nProcs: the number of processors the benchmark will run on
    
    properties
        function_name;
        dataSize = 'small';
    end
    
    methods
        function obj = test_bm_gen_sqw_smallData(test_class_name)
            %TEST_BM_GEN_SQW_SMALLDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_gen_sqw_smallData';
            end
            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_gen_sqw_smallData_smallNumber_smallDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'small';
            detectorSize = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_mediumNumber_smallDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'medium';
            detectorSize = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_largeNumber_smallDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'large';
            detectorSize = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_smallNumber_mediumDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'small';
            detectorSize = 'medium';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_mediumNumber_mediumDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'medium';
            detectorSize = 'medium';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_largeNumber_mediumDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'large';
            detectorSize = 'medium';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_smallNumber_largeDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'small';
            detectorSize = 'large';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_mediumNumber_largeDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'medium';
            detectorSize = 'large';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

        function test_bm_gen_sqw_smallData_largeNumber_largeDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'large';
            detectorSize = 'large';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
        end

%% The following benchmarks are for multi-processor/parallel-enabled codes

%         function test_bm_gen_sqw_smallData_smallNumber_smallDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_mediumNumber_smallDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_largeNumber_smallDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_smallNumber_mediumDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_mediumNumber_mediumDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_largeNumber_mediumDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_smallNumber_largeDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_mediumNumber_largeDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_largeNumber_largeDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_smallNumber_smallDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_mediumNumber_smallDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_largeNumber_smallDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_smallNumber_mediumDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_mediumNumber_mediumDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_largeNumber_mediumDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_smallNumber_largeDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_mediumNumber_largeDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_smallData_largeNumber_largeDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
    end
end

