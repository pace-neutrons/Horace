classdef test_bm_cut_sqw_largeData < TestCase
%TEST_BM_CUT_SQW_LARGEDATA largeData Benchmark class for cut_sqw()
% This set of benchmarks uses "large" sized sqw objects created using 
% dummy_sqw (10^9 pixels).
% The parameters that are varied in this set of benchmarks are:
%   - nDims: the dimensions of the sqw objects to combine: 1,2 or 3
%   - objType: the type of object to cut: sqw or dnd
%   - nProcs: the number of processors the benchmarks will run on
%   - eRange: the binning along the energy axis: see p4_bin in "help sqw/cut"

    properties
        function_name;
        common_data;
        dataSize = 'large';
    end
    
    methods
        function obj = test_bm_cut_sqw_largeData(test_class_name)
            %The constructor cut_sqw class

            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_cut_sqw_largeData';
            end
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
        end
% ocr96: Currently running into Out of Memory error in Anvil when running largeData test
% commented out untill appropriate data size is chosen or memory issue in
% Anvil resolved

%         function test_bm_cut_sqw_largeData_3D_sqw_largeEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_2D_sqw_largeEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_1D_sqw_largeEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_3D_dnd_largeEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_2D_dnd_largeEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_1D_dnd_largeEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_3D_sqw_mediumEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_2D_sqw_mediumEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_1D_sqw_mediumEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_3D_dnd_mediumEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_2D_dnd_mediumEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_1D_dnd_mediumEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_3D_sqw_smallEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_2D_sqw_smallEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_1D_sqw_smallEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_3D_dnd_smallEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_2D_dnd_smallEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_largeData_1D_dnd_smallEnergy_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,false);
%         end
% 
%         function test_bm_cut_sqw_contiguous_largeData_2D_sqw_mediumE_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,true);
%         end
% 
%         function test_bm_cut_sqw_contiguous_largeData_1D_sqw_mediumE_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,true);
%         end
% 
%         function test_bm_cut_sqw_contiguous_largeData_2D_dnd_mediumE_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,true);
%         end
% 
%         function test_bm_cut_sqw_contiguous_largeData_1D_dnd_mediumE_1procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 1;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs,...
%                 eRange,true);
%         end

%% Below functions are for when cut_sqw is parallelised: using 2 and 4 processors

%         function test_bm_cut_sqw_largeData_3D_sqw_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;             
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_sqw_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_sqw_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_contiguous_largeData_2D_sqw_mediumE_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true);
%         end
%
%         function test_bm_cut_sqw_contiguous_largeData_1D_sqw_mediumE_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true);
%         end
% 
%         function test_bm_cut_sqw_contiguous_largeData_2D_dnd_mediumE_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true);
%         end
%
%         function test_bm_cut_sqw_contiguous_largeData_1D_dnd_mediumE_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;             
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_3D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_2D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_largeData_1D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,false);
%         end
%
%         function test_bm_cut_sqw_contiguous_largeData_2D_sqw_mediumE_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true);
%         end
%
%         function test_bm_cut_sqw_contiguous_largeData_1D_sqw_mediumE_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true);
%         end
%
%         function test_bm_cut_sqw_contiguous_largeData_2D_dnd_mediumE_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true);
%         end
%
%         function test_bm_cut_sqw_contiguous_largeData_1D_dnd_mediumE_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSize,objType,nProcs...
%             ,eRange,true                                );
%         end
    end
end