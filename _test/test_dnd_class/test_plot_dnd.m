classdef test_plot_dnd < TestCase
    % Test plotting methods on sqw and dnd objects
    properties
        sqw_1d_file = 'sqw_1d_1.sqw';
        sqw_2d_file = 'sqw_2d_1.sqw';
        sqw_3d_file = 'w3d_sqw.sqw';
        sqw_4d_file = 'sqw_4d.sqw';
        dnd_obj

        interface_tester = data_plot_interface_tester();
    end

    methods

        function obj = test_plot_dnd(varargin)
            obj = obj@TestCase('test_plot_dnd');

            hp = horace_paths();
            tst_files = {fullfile(hp.test_common,obj.sqw_1d_file),...
                fullfile(hp.test_common,obj.sqw_2d_file),...
                fullfile(hp.test_common,obj.sqw_3d_file),...
                fullfile(hp.test_common,obj.sqw_4d_file)};
            obj.dnd_obj = cell(4,1);
            obj.dnd_obj = cellfun(@(x)read_dnd(x),tst_files, ...
                'UniformOutput',false);
        end
        %------------------------------------------------------------------
        function test_d4d_all_plot_methods_throw(obj)
            d4d_obj = obj.dnd_obj{4};
            tstd = obj.interface_tester;
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d2d_methods(:);tstd.d3d_methods(:)];
            errors_list = {'HORACE:DnDBase:not_implemented',...
                'HERBERT:graphics:invalid_argument','HORACE:d4d:invalid_argument'};
            err_ind = ones(numel(other_methods),1);
            err_ind(26) = 2;
            err_ind(28) = 3;
            err_ind(29) = 3;
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d4d_obj,other_methods{i}), ...
                    errors_list{err_ind(i)}, ...
                    sprintf('error for method N%d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end

        %------------------------------------------------------------------
        function test_d3d_other_plot_methods_throw(obj)
            d3d_obj = obj.dnd_obj{3};
            tstd = obj.interface_tester;
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d2d_methods(:)];
            errors_list = {'HORACE:DnDBase:not_implemented',...
                'HERBERT:graphics:invalid_argument'};
            err_ind = ones(numel(other_methods),1);
            err_ind(26) = 2;
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d3d_obj,other_methods{i}), ...
                    errors_list{err_ind(i)}, ...
                    sprintf('error for method N%d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        %
        function test_d3d_plot3D_methods_work(obj)
            d3d_obj = obj.dnd_obj{3};
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
            d2d_obj = obj.dnd_obj{2};
            tstd = obj.interface_tester;
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d3d_methods(:)];
            errors_list = {'HORACE:DnDBase:not_implemented',...
                'HORACE:d2d:invalid_argument'};
            err_ind = ones(numel(other_methods),1);
            err_ind(19) = 2;
            err_ind(20) = 2;
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d2d_obj,other_methods{i}), ...
                    errors_list{err_ind(i)}, ...
                    sprintf('error for method N%d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        %
        function test_d2d_plot2D_methods_work(obj)
            d2d_obj = obj.dnd_obj{2};
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
            d1d_obj = obj.dnd_obj{1};
            tstd = obj.interface_tester;
            other_methods = [tstd.d2d_methods(:);tstd.d3d_methods(:)];
            errors_list = {'HORACE:DnDBase:not_implemented',...
                'HERBERT:graphics:invalid_argument','HORACE:d1d:invalid_argument'};
            err_ind = ones(numel(other_methods),1);
            err_ind(8) = 2;
            err_ind(10) = 3;
            err_ind(11) = 3;
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(d1d_obj,other_methods{i}), ...
                    errors_list{err_ind(i)}, ...
                    sprintf('error for method N%d: %s',i, ...
                    func2str(other_methods{i})));
            end

        end
        function test_d1d_plot1D_methods_work(obj)
            d1d_obj = obj.dnd_obj{1};
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
                    'HORACE:data_plot_interface_tester:invalid_argument');
            end
        end
    end
end
