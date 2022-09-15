classdef test_bm_gen_sqw_largeData < TestCase
%TEST_BM_GEN_SQW_LARGEDATA largeData Benchmark class for gen_sqw()
% This set of benchmarks uses "large" sized nxspe files to generate 
% sqw objects.The nxspe files are created using dummy_spe, with Energy 
% bin boundaries of 0:4:787 (largeData).
% Inputs:
%   - dataSet: the amount of nxspe files used to generate an sqw obj.
%            'small', 'medium' or 'large' (12, 23 and 46 files respectively)
%            or an integer amount of files.
%   - detectorNum: the amount of detectors used to generate a
%            the needed par_file info. 'small', 'medium' or 'large'.
%            Corresponding to MAPS, MERLIN and LET. 
%   - nProcs: the number of processors the benchmark will run on
    
    properties
        function_name;
        dataSize = 'large';
    end
    
    methods
        function obj = test_bm_gen_sqw_largeData(test_class_name)
            %TEST_BM_GEN_SQW_LARGEDATA Construct an instance of this class
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_gen_sqw_largeData';
            end
            obj = obj@TestCase(test_class_name);
        end

% ocr96: Currently running into Out of Memory error in Anvil when running largeData test
% commented out untill appropriate data size is chosen or memory issue in
% Anvil resolved
        
%         function test_bm_gen_sqw_largeData_smallNumber_smallDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'small';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_smallDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'small';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_smallDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'small';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_smallNumber_mediumDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'medium';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_mediumDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'medium';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_mediumDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'medium';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_smallNumber_largeDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'large';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_largeDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'large';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_largeDetector_1procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'large';
%             nProcs = 1;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
        
%% The following benchmarks are for multi-processor/parallel-enabled codes

%         function test_bm_gen_sqw_largeData_smallNumber_smallDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_smallDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_smallDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_smallNumber_mediumDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_mediumDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_mediumDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_smallNumber_largeDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_largeDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_largeDetector_2procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_smallNumber_smallDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_smallDetector_4procs(obj)
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_smallDetector_4procs(obj)
%             % Benchmarking using "large" data (ebin = 0:4:787), 46 nxspe files, 
%             % small sized par_file (32768 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_smallNumber_mediumDetector_4procs(obj)
%             % Benchmarking using "large" data (ebin = 0:4:787), 12 nxspe files, 
%             % medium sized par_file (46656 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_mediumDetector_4procs(obj)
%             % Benchmarking using "large" data (ebin = 0:4:787), 23 nxspe files, 
%             % medium sized par_file (46656 detectors) and 4 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_mediumDetector_4procs(obj)
%             % Benchmarking using "large" data (ebin = 0:4:787), 46 nxspe files, 
%             % medium sized par_file (46656 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_smallNumber_largeDetector_4procs(obj)
%             % Benchmarking using "large" data (ebin = 0:4:787), 12 nxspe files, 
%             % large sized par_file (74088 detectors) and 4 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_mediumNumber_largeDetector_4procs(obj)
%             % Benchmarking using "large" data (ebin = 0:4:787), 23 nxspe files, 
%             % large sized par_file (74088 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
% 
%         function test_bm_gen_sqw_largeData_largeNumber_largeDetector_4procs(obj)
%             % Benchmarking using "large" data (ebin = 0:4:787), 46 nxspe files, 
%             % large sized par_file (74088 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs);
%         end
    end
end

