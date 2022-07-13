classdef test_bm_cut_sqw_smallData < TestCase
    %test_bm_cut_sqw has the benchmark tests for the cut_sqw function 
        
    properties 
        function_name;
%         par_file;
%         efix;
%         emode;
%         alatt;
%         angdeg;
%         u;
%         v;
%         psi;
%         omega;
%         dpsi;
%         gl;
%         gs;
    end
    
    methods

        function obj = test_bm_cut_sqw_smallData(test_class_name)
            %The constructor cut_sqw class

            if ~exist('test_class_name','var')
                test_class_name = 'test_bm_cut_sqw_smallData';
            end

            obj = obj@TestCase(test_class_name);

        end
        
        function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 3;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'large';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'large';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'large';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 3;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'large';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'large';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'large';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 3;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 3;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 3;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'small';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end
        
        function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'small';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'small';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 3;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'small';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'small';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'small';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
        end

        function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'ture');
        end

        function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='sqw';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'true');
        end

        function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 2;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'ture');
        end

        function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_1procs(obj)
            function_stack = dbstack;
            func_name = function_stack.name;
            obj.function_name = func_name + ".csv"; 
            nDims = 1;
            data = "ironSmall";
            dataSource = gen_bm_cut_data(data);
            objType='dnd';
            nProcs = 1;
            eRange = 'medium';
            benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'true');
        end

%% Below functions are for when cut_sqw is parallelised: using 2 and 4 processors

%         function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 1;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
%         
%         function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'ture');
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'true');
%         end

%         function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'ture');
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_2procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 2;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'true');
%         end
%         
%         function test_bm_cut_sqw_smallData_3D_sqw_largeEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_sqw_largeEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_sqw_largeEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_dnd_largeEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_dnd_largeEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_dnd_largeEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'large';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_sqw_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_sqw_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_sqw_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_dnd_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_dnd_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_dnd_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_sqw_smallEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
%         
%         function test_bm_cut_sqw_smallData_2D_sqw_smallEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_sqw_smallEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_3D_dnd_smallEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 3;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_2D_dnd_smallEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_smallData_1D_dnd_smallEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'small';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,false);
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_2D_sqw_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'ture');
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_1D_sqw_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='sqw';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'true');
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_2D_dnd_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 2;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'ture');
%         end
% 
%         function test_bm_cut_sqw_contiguous_smallData_1D_dnd_mediumEnergy_4procs(obj)
%             function_stack = dbstack;
%             func_name = function_stack.name;
%             obj.function_name = func_name + ".csv"; 
%             nDims = 1;
%             data = "ironSmall";
%             dataSource = gen_bm_cut_data(data);
%             objType='dnd';
%             nProcs = 4;
%             eRange = 'medium';
%             benchmark_cut_sqw(nDims,dataSource,objType,nProcs,eRange,obj.function_name,'true');
%         end
    end
    
end