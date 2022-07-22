classdef test_plot_sqw_dnd < TestCase
    % Test plotting methods on sqw and dnd objects
    properties
        sqw_1d_file = 'sqw_1d_1.sqw';
        sqw_2d_file = 'sqw_2d_1.sqw';
        sqw_3d_file = 'w3d_sqw.sqw';
        sqw_4d_file = 'sqw_4d.sqw';
        sqw_obj

        interface_tester = SqwDndPlot_interface_tester();
    end

    methods

        function obj = test_plot_sqw_dnd(varargin)
            obj = obj@TestCase('test_plot_sqw_dnd');
            test_folder = fileparts(fileparts(mfilename('fullpath')));
            tst_files = {fullfile(test_folder,'common_data',obj.sqw_1d_file),...
                fullfile(test_folder,'common_data',obj.sqw_2d_file),...
                fullfile(test_folder,'common_data',obj.sqw_3d_file),...
                fullfile(test_folder,'common_data',obj.sqw_4d_file)};
            obj.sqw_obj = cell(4,1);
            for i = 1:4
                obj.sqw_obj{i} = read_sqw(tst_files{i});
            end
        end
        %------------------------------------------------------------------
        function test_sqw4d_all_plot_methods_throw(obj)
            sqw4d_obj = obj.sqw_obj{4};
            tstd = obj.interface_tester;    
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d2d_methods(:);tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(sqw4d_obj,other_methods{i}), ...
                    'HORACE:d4d:runtime_error');
            end            
        end
        
        %------------------------------------------------------------------
        function test_sqw3d_other_plot_methods_throw(obj)
            sqw3d_obj =obj.sqw_obj{3};
            tstd = obj.interface_tester;    
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d2d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(sqw3d_obj,other_methods{i}), ...
                    'HORACE:d3d:runtime_error');
            end            
        end
        %
        function test_sqw3d_plot3D_methods_work(obj)
            sqw3d_obj = obj.sqw_obj{3};
            tstd = obj.interface_tester;            
            pl_methods = [{@plot};tstd.d3d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(sqw3d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;                    
            end
            close(objh);
        end        
        %------------------------------------------------------------------
        function test_sqw2d_other_plot_methods_throw(obj)
            sqw2d_obj = obj.sqw_obj{2};
            tstd = obj.interface_tester;    
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(sqw2d_obj ,other_methods{i}), ...
                    'HORACE:d2d:runtime_error');
            end            
        end
        %
        function test_sqw2d_plot2D_methods_work(obj)
            sqw2d_obj = obj.sqw_obj{2};
            tstd = obj.interface_tester;            
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(sqw2d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;                    
            end
            close(objh);
        end
        %------------------------------------------------------------------
        function test_sqw1d_other_plot_methods_throw(obj)
            sqw1d_obj = obj.sqw_obj{1};
            tstd = obj.interface_tester;    
            other_methods = [tstd.d2d_methods(:);tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(sqw1d_obj,other_methods{i}), ...
                    'HORACE:d1d:runtime_error');
            end
            
        end
        function test_sqw1d_plot1D_methods_work(obj)
            sqw1d_obj = obj.sqw_obj{1};
            tstd = obj.interface_tester;            
            pl_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(sqw1d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;                    
            end
            opl_methods = tstd.d1d_mthods_oveplot;
            for i=1:numel(opl_methods)
                meth = opl_methods{i};

                oboh = meth(sqw1d_obj);
                assertEqual(oboh,objh)
            end
            close(oboh);
        end
        %------------------------------------------------------------------
        
        %------------------------------------------------------------------
        function test_d4d_all_plot_methods_throw(obj)
            d4d_obj = dnd(obj.sqw_obj{4});
            tstd = obj.interface_tester;    
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d2d_methods(:);tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d4d_obj,other_methods{i}), ...
                    'HORACE:d4d:runtime_error');
            end            
        end
        
        %------------------------------------------------------------------
        function test_d3d_other_plot_methods_throw(obj)
            d3d_obj = dnd(obj.sqw_obj{3});
            tstd = obj.interface_tester;    
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d2d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d3d_obj,other_methods{i}), ...
                    'HORACE:d3d:runtime_error');
            end            
        end
        %
        function test_d3d_plot3D_methods_work(obj)
            d3d_obj = dnd(obj.sqw_obj{3});
            tstd = obj.interface_tester;            
            pl_methods = [{@plot};tstd.d3d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(d3d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;                    
            end
            close(objh);
        end
        
        %------------------------------------------------------------------
        function test_d2d_other_plot_methods_throw(obj)
            d2d_obj = dnd(obj.sqw_obj{2});
            tstd = obj.interface_tester;    
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d2d_obj,other_methods{i}), ...
                    'HORACE:d2d:runtime_error');
            end            
        end
        %
        function test_d2d_plot2D_methods_work(obj)
            d2d_obj = dnd(obj.sqw_obj{2});
            tstd = obj.interface_tester;            
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(d2d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;                    
            end
            close(objh);
        end
        %------------------------------------------------------------------
        function test_d1d_other_plot_methods_throw(obj)
            d1d_obj = dnd(obj.sqw_obj{1});
            tstd = obj.interface_tester;    
            other_methods = [tstd.d2d_methods(:);tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d1d_obj,other_methods{i}), ...
                    'HORACE:d1d:runtime_error');
            end
            
        end
        function test_d1d_plot1D_methods_work(obj)
            d1d_obj = dnd(obj.sqw_obj{1});
            tstd = obj.interface_tester;            
            pl_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(d1d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;                    
            end
            opl_methods = tstd.d1d_mthods_oveplot;
            for i=1:numel(opl_methods)
                meth = opl_methods{i};

                oboh = meth(d1d_obj);
                assertEqual(oboh,objh)
            end
            close(oboh);
        end
        %------------------------------------------------------------------
        function test_SqwDnDPlotInterface_throws(obj)
            tstd = obj.interface_tester;
            all_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:);...
                tstd.d2d_methods(:);tstd.d3d_methods(:)];
            function thrower(tstd,fmethod)
                fmethod(tstd);
            end
            for i=1:numel(all_methods)
                assertExceptionThrown(@()thrower(tstd,all_methods{i}), ...
                    'HORACE:SqwDndPlot_interface_tester:runtime_error');
            end
        end
    end
end
