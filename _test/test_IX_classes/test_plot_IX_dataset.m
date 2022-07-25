classdef test_plot_IX_dataset < TestCase
    % Test plotting methods on sqw and dnd objects
    properties
        sqw_1d_file = 'sqw_1d_1.sqw';
        sqw_2d_file = 'sqw_2d_1.sqw';
        sqw_3d_file = 'w3d_sqw.sqw';
        IX_data

        interface_tester = data_plot_interface_tester();
    end

    methods

        function obj = test_plot_IX_dataset(varargin)
            obj = obj@TestCase('test_plot_dnd');
            test_folder = fileparts(fileparts(mfilename('fullpath')));
            tst_files = {fullfile(test_folder,'common_data',obj.sqw_1d_file),...
                fullfile(test_folder,'common_data',obj.sqw_2d_file),...
                fullfile(test_folder,'common_data',obj.sqw_3d_file)};
            obj.IX_data = cell(4,1);
            for i = 1:3
                obj.IX_data{i} = read_dnd(tst_files{i});
            end
            %TODO: should be something similar to dnd here:
            obj.IX_data{1} = obj.IX_data{1}.IX_dataset_1d();
            obj.IX_data{2} = obj.IX_data{2}.IX_dataset_2d();
            obj.IX_data{3} = obj.IX_data{3}.IX_dataset_3d();
        end
        %------------------------------------------------------------------
        function test_IXd3d_other_plot_methods_throw(obj)
            IXd3d_obj = obj.IX_data{3};
            tstd = obj.interface_tester;
            other_methods = ...
                [{@sliceomatic_overview};...
                tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d2d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(IXd3d_obj,other_methods{i}), ...
                    'HORACE:IX_dataset_3d:invalid_argument', ...
                    sprintf('error for method N%d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        %
        function test_IXd3d_plot3D_methods_work(obj)
            IXd3d_obj = obj.IX_data{3};
            tstd = obj.interface_tester;
            meth = tstd.d3d_methods;
            is_slic = cellfun(@(x)(strcmp(func2str(x),'sliceomatic_overview')),...
                meth);
            pl_methods = [{@plot};meth(~is_slic)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(IXd3d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;
            end
            close(objh);
        end

        %------------------------------------------------------------------
        function test_IXd2d_other_plot_methods_throw(obj)
            IXd2d_obj = obj.IX_data{2};
            tstd = obj.interface_tester;
            other_methods = ...
                [tstd.d1d_methods(:);...
                tstd.d1d_mthods_oveplot(:);...
                tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(IXd2d_obj,other_methods{i}), ...
                    'HORACE:IX_dataset_2d:invalid_argument', ...
                    sprintf('error for method N%d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        %
        function test_IXd2d_plot2D_methods_work(obj)
            IXd2d_obj = obj.IX_data{2};
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(IXd2d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;
            end
            close(objh);
        end
        %------------------------------------------------------------------
        function test_IX1d_other_plot_methods_throw(obj)
            IX1d_obj = obj.IX_data{1};
            tstd = obj.interface_tester;
            other_methods = [tstd.d2d_methods(:);tstd.d3d_methods(:)];
            function thrower(obx,fmethod)
                fmethod(obx);
            end
            for i=1:numel(other_methods)
                assertExceptionThrown(@()thrower(IX1d_obj,other_methods{i}), ...
                    'HORACE:IX_dataset_1d:invalid_argument', ...
                    sprintf('error for method N%d: %s',i, ...
                    func2str(other_methods{i})));
            end

        end
        function test_IX1d_plot1D_methods_work(obj)
            IX1d_obj = obj.IX_data{1};
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                objh = meth(IX1d_obj);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                if ~isempty(prev_h) && prev_h ~= objh
                    close(prev_h)
                end
                prev_h = objh;
            end
            opl_methods = tstd.d1d_mthods_oveplot;
            for i=1:numel(opl_methods)
                meth = opl_methods{i};

                oboh = meth(IX1d_obj);
                assertEqual(oboh,objh)
            end
            close(oboh);
        end
    end
end
