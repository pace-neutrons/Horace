classdef test_bm_cut_sqw_smallData < TestCase
<<<<<<< HEAD
<<<<<<< HEAD
    %test_bm_cut_sqw has the benchmark tests for the cut_sqw function

    properties
        function_name;
        common_data;
        dataSize = 'small';
<<<<<<< HEAD
<<<<<<< HEAD
        dataSource;
        
=======
>>>>>>> 8d4db5de5 (updating gen_data functions)
=======
        dataSource;
        
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
    end

=======
    %test_bm_cut_sqw has the benchmark tests for the cut_sqw function 
        
    properties 
=======
    %test_bm_cut_sqw has the benchmark tests for the cut_sqw function

    properties
>>>>>>> 7a8c2792b (Use horace_paths object)
        function_name;
        common_data;
    end
<<<<<<< HEAD
    
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======

>>>>>>> 7a8c2792b (Use horace_paths object)
    methods

        function obj = test_bm_cut_sqw_smallData(test_class_name)
            %The constructor cut_sqw class

            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_cut_sqw_smallData';
            end
<<<<<<< HEAD
<<<<<<< HEAD
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData6.sqw');

        end

        function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="sqw";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="dnd";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="sqw";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="dnd";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,true);
        end

        function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,true);
        end

        function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,true);
        end

        function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,true);
=======

=======
>>>>>>> 7a8c2792b (Use horace_paths object)
            obj = obj@TestCase(test_class_name);
            pths = horace_paths;
            obj.common_data = pths.bm_common;
            obj.dataSource = fullfile(obj.common_data,'NumData6.sqw');

        end

        function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="sqw";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="dnd";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "large";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="sqw";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 3;
            objType="dnd";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "small";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,true);
        end

        function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="sqw";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,true);
        end

        function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 2;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
                eRange,obj.function_name,true);
        end

        function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_1procs(obj)
            obj.function_name = get_bm_name();
            nDims = 1;
            objType="dnd";
            nProcs = 1;
            eRange = "medium";
<<<<<<< HEAD
<<<<<<< HEAD
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'true');
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======
            benchmark_cut_sqw(nDims,dataSource,obj.dataSize,objType,nProcs,...
=======
            benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,...
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
                eRange,obj.function_name,true);
>>>>>>> 8d4db5de5 (updating gen_data functions)
        end

%% Below functions are for when cut_sqw is parallelised: using 2 and 4 processors

%         function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_2procs(obj)
<<<<<<< HEAD
<<<<<<< HEAD
%             obj.function_name = get_bm_name();
%             nDims = 3;             
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'ture');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'ture');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;             
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'ture');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
    end

=======
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
=======
%             obj.function_name = get_bm_name();
<<<<<<< HEAD
>>>>>>> 89ccf4ee9 (Replace duplicated code (#833))
%             nDims = 3;
%
=======
%             nDims = 3;             
<<<<<<< HEAD
>>>>>>> 8d4db5de5 (updating gen_data functions)
%             dataSource = fullfile(obj.common_data,'NumData6.sqw');
=======
>>>>>>> ab0cb176e (making dataSize and dataSource class Properties)
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'ture');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'ture');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_2procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 2;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "large";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;             
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 3;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "small";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,false);
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="sqw";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 2;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'ture');
%         end
%
%         function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_4procs(obj)
%             obj.function_name = get_bm_name();
%             nDims = 1;
%             objType="dnd";
%             nProcs = 4;
%             eRange = "medium";
%             benchmark_cut_sqw(nDims,obj.dataSource,obj.dataSize,objType,nProcs,eRange,obj.function_name,'true');
%         end
    end
<<<<<<< HEAD
    
>>>>>>> 4ad9d7cfa (add first benchmarking version)
=======

>>>>>>> 7a8c2792b (Use horace_paths object)
end