classdef test_plot_sqw < TestCase
    % Test plotting methods on sqw and dnd objects
    properties
        sqw_1d_file = 'sqw_1d_1.sqw';
        sqw_2d_file = 'sqw_2d_1.sqw';
        sqw_3d_file = 'w3d_sqw.sqw';
        sqw_4d_file = 'sqw_4d.sqw';
        sqw_obj

        interface_tester = data_plot_interface_tester();
    end

    methods

        function obj = test_plot_sqw(varargin)
            obj = obj@TestCase('test_plot_sqw');
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
            errors_list = {'HORACE:DnDBase:not_implemented',...
                'HORACE:d4d:invalid_argument'};
            err_ind = ones(numel(other_methods),1);
            err_ind(28) = 2;
            err_ind(29) = 2;

            function thrower(obx,fmethod)
                fmethod(obx);
            end
            overplot_names = cellfun(@func2str,tstd.d2d_methods,'UniformOutput',false);
            for i=1:numel(other_methods)
                curr_meth_name = func2str(other_methods{i});
                is_overplot = ismember(curr_meth_name,overplot_names);

                if is_overplot
                    plot(obj.sqw_obj{2})
                    fh = gcf;
                else
                    fh = [];
                end
                assertExceptionThrown(@()thrower(sqw4d_obj,other_methods{i}), ...
                    errors_list{err_ind(i)});

                if ~isempty(fh)
                    close(fh);
                end
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
            errors_list = {'HORACE:DnDBase:not_implemented'};
            err_ind = ones(numel(other_methods),1);


            function thrower(obx,fmethod)
                fmethod(obx);
            end
            overplot_names = cellfun(@func2str,tstd.d2d_methods,'UniformOutput',false);
            for i=1:numel(other_methods)
                curr_meth_name = func2str(other_methods{i});
                is_overplot = ismember(curr_meth_name,overplot_names);
                if is_overplot
                    plot(obj.sqw_obj{2})
                    fh = gcf;
                else
                    fh = [];
                end

                assertExceptionThrown(@()thrower(sqw3d_obj,other_methods{i}), ...
                    errors_list{err_ind(i)});

                if ~isempty(fh)
                    close(fh);
                end

            end
        end
        function test_sqw3d_plot3D_methods_work_on_array(obj)
            sqw3d_obj = obj.sqw_obj{3};
            sqw3d_ar = [sqw3d_obj,sqw3d_obj];
            tstd = obj.interface_tester;
            pl_methods = [{@plot};tstd.d3d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(sqw3d_ar);

                assertEqual(numel(objh),2)
                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isstruct(plh));

                if ~isempty(prev_h) && any(prev_h ~= objh)
                    close(prev_h);
                end
                prev_h = objh;
            end
            try
                close(objh);
            catch
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

                [objh,axh,plh] = meth(sqw3d_obj);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isstruct(plh));

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
            errors_list = {'HORACE:DnDBase:not_implemented',...
                'HORACE:d2d:invalid_argument'};
            err_ind = ones(numel(other_methods),1);
            err_ind(19) = 2;
            err_ind(20) = 2;

            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(sqw2d_obj ,other_methods{i}), ...
                    errors_list{err_ind(i)});
            end
        end
        %
        function test_sqw2d_plot2D_methods_work_on_array(obj)
            sqw2d_obj = obj.sqw_obj{2};
            sqw2d_arr = [sqw2d_obj,sqw2d_obj];
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];
            need_overplot = [false;false;tstd.overplot_requested(:)];

            for i=1:numel(pl_methods)
                meth = pl_methods{i};
                if need_overplot(i)
                    fig = figure;
                end

                [objh,axh,plh] = meth(sqw2d_arr);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));
                close(objh);
            end

        end

        function test_sqw2d_plot2D_methods_work(obj)
            sqw2d_obj = obj.sqw_obj{2};
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(sqw2d_obj);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

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
            errors_list = {'HORACE:DnDBase:not_implemented',...
                'HORACE:d1d:invalid_argument'};
            err_ind = ones(numel(other_methods),1);
            err_ind(10) = 2;
            err_ind(11) = 2;

            function thrower(obx,fmethod)
                fmethod(obx);
            end
            overplot_names = cellfun(@func2str,tstd.d2d_methods,'UniformOutput',false);
            for i=1:numel(other_methods)
                curr_meth_name = func2str(other_methods{i});
                is_overplot = ismember(curr_meth_name,overplot_names);

                if is_overplot
                    plot(obj.sqw_obj{2})
                    fh = gcf;
                else
                    fh = [];
                end
                assertExceptionThrown(@()thrower(sqw1d_obj,other_methods{i}), ...
                    errors_list{err_ind(i)} );

                if ~isempty(fh)
                    close(fh);
                end
            end
        end
        function test_sqw1d_plot1D_methods_work_on_array(obj)
            sqw1d_obj = obj.sqw_obj{1};
            sqw1d_arr = [sqw1d_obj,sqw1d_obj];
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(sqw1d_arr);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

                if ~isempty(prev_h) && all(prev_h ~= objh)
                    close(prev_h)
                end
                prev_h = objh;
            end
            opl_methods = tstd.d1d_mthods_oveplot;
            for i=1:numel(opl_methods)
                meth = opl_methods{i};

                oboh = meth(sqw1d_arr);
                assertEqual(oboh,objh)
            end
            close(oboh);
        end

        function test_sqw1d_plot1D_methods_work(obj)
            sqw1d_obj = obj.sqw_obj{1};
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(sqw1d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;
            end
            opl_methods = tstd.d1d_mthods_oveplot;
            for i=1:numel(opl_methods)
                meth = opl_methods{i};

                oboh = meth(sqw1d_obj);
                [objh,axh,plh] = meth(sqw1d_obj);

                assertEqual(oboh,objh)
                assertTrue(numel(plh)>1);
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));
            end
            close(oboh);
        end
        %------------------------------------------------------------------
    end
end
