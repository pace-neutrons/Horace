classdef test_bm_gen_sqw_mediumData < TestCase
%TEST_BM_GEN_SQW_MEDIUMDATA mediumData Benchmark class for gen_sqw()
% This set of benchmarks uses "medium" sized nxspe files to generate 
% sqw objects.The nxspe files are created using dummy_spe, with Energy 
% bin boundaries of 0:8:787 (mediumData).
% Inputs:
%   - dataSet: the amount of nxspe files used to generate an sqw obj.
%            'small', 'medium' or 'large' (12, 23 and 46 files respectively)
%            or an integer amount of files.
%   - detectorNum: the amount of detectors used to generate a
%            the needed detector info. 'small', 'medium' or 'large' (32768,
%            46656, 74088 respectively)
%   - nProcs: the number of processors the benchmark will run on
    
    properties
        function_name;
        dataSize = 'medium';
    end
    
    methods
        function obj = test_bm_gen_sqw_mediumData(test_class_name)
            %TEST_BM_GEN_SQW_MEDIUMDATA Construct an instance of this class
            %   Detailed explanation goes here
            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_gen_sqw_mediumData';
            end
            obj = obj@TestCase(test_class_name);
        end
        
        function test_bm_gen_sqw_mediumData_smallNumber_smallDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'small';
            detectorSize = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_mediumNumber_smallDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'medium';
            detectorSize = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_largeNumber_smallDetector_1procs(obj)
            obj.function_name = get_bm_name();
            dataSet = 'large';
            detectorSize = 'small';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_smallNumber_mediumDetector_1procs(obj)
            % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
            % medium sized par_file (46656 detectors) and 1 processor
            obj.function_name = get_bm_name();
            dataSet = 'small';
            detectorSize = 'medium';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_mediumNumber_mediumDetector_1procs(obj)
            % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
            % medium sized par_file (46656 detectors) and 1 processor 
            obj.function_name = get_bm_name();
            dataSet = 'medium';
            detectorSize = 'medium';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_largeNumber_mediumDetector_1procs(obj)
            % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
            % medium sized par_file (46656 detectors) and 1 processor
            obj.function_name = get_bm_name();
            dataSet = 'large';
            detectorSize = 'medium';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_smallNumber_largeDetector_1procs(obj)
            % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
            % large sized par_file (74088 detectors) and 1 processor 
            obj.function_name = get_bm_name();
            dataSet = 'small';
            detectorSize = 'large';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_mediumNumber_largeDetector_1procs(obj)
            % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
            % large sized par_file (74088 detectors) and 1 processor
            obj.function_name = get_bm_name();
            dataSet = 'medium';
            detectorSize = 'large';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end

        function test_bm_gen_sqw_mediumData_largeNumber_largeDetector_1procs(obj)
            % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
            % large sized par_file (74088 detectors) and 1 processor
            obj.function_name = get_bm_name();
            dataSet = 'large';
            detectorSize = 'large';
            nProcs = 1;
            benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
        end
%% The following benchmarks are for multi-processor/parallel-enabled codes

%         function test_bm_gen_sqw_mediumData_smallNumber_smallDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
%             % small sized par_file (32768 detectors) and 2 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_mediumNumber_smallDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
%             % small sized par_file (32768 detectors) and 2 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_largeNumber_smallDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
%             % small sized par_file (32768 detectors) and 2 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'small';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_smallNumber_mediumDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
%             % medium sized par_file (46656 detectors) and 2 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_mediumNumber_mediumDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
%             % medium sized par_file (46656 detectors) and 2 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_largeNumber_mediumDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
%             % medium sized par_file (46656 detectors) and 2 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'medium';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_smallNumber_largeDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
%             % large sized par_file (74088 detectors) and 2 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_mediumNumber_largeDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
%             % large sized par_file (74088 detectors) and 2 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_largeNumber_largeDetector_2procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
%             % large sized par_file (74088 detectors) and 2 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'large';
%             nProcs = 2;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_smallNumber_smallDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
%             % small sized par_file (32768 detectors) and 4 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_mediumNumber_smallDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
%             % small sized par_file (32768 detectors) and 4 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_largeNumber_smallDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
%             % small sized par_file (32768 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'small';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_smallNumber_mediumDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
%             % medium sized par_file (46656 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_mediumNumber_mediumDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
%             % medium sized par_file (46656 detectors) and 4 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_largeNumber_mediumDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
%             % medium sized par_file (46656 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'medium';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_smallNumber_largeDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 12 nxspe files, 
%             % large sized par_file (74088 detectors) and 4 processors 
%             obj.function_name = get_bm_name();
%             dataSet = 'small';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_mediumNumber_largeDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 23 nxspe files, 
%             % large sized par_file (74088 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'medium';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
% 
%         function test_bm_gen_sqw_mediumData_largeNumber_largeDetector_4procs(obj)
%             % Benchmarking using "medium" data (ebin = 0:8:787), 46 nxspe files, 
%             % large sized par_file (74088 detectors) and 4 processors
%             obj.function_name = get_bm_name();
%             dataSet = 'large';
%             detectorSize = 'large';
%             nProcs = 4;
%             benchmark_gen_sqw(obj.dataSize,dataSet,detectorSize,nProcs,obj.function_name);
%         end
    end
end

