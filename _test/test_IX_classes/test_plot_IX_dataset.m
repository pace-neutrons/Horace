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
            hp = horace_paths;
            tst_files = {fullfile(hp.test_common,obj.sqw_1d_file),...
                fullfile(hp.test_common,obj.sqw_2d_file),...
                fullfile(hp.test_common,obj.sqw_3d_file)};
            obj.IX_data = cell(4,1);
            for i = 1:3
                obj.IX_data{i} = read_dnd(tst_files{i});
            end
            %TODO: should be something similar to dnd here:
            obj.IX_data{1} = obj.IX_data{1}.IX_dataset_1d();
            obj.IX_data{2} = obj.IX_data{2}.IX_dataset_2d();
            obj.IX_data{3} = obj.IX_data{3}.IX_dataset_3d();
            close all;
        end
        %------------------------------------------------------------------
        function test_spaghetti_noplot(obj)
            tob = [obj.IX_data{2};obj.IX_data{2}*2;obj.IX_data{2}*0.5];
            [ds,cuts,figh,axh,plh] = spaghetti_plot(tob,'noplot');
            assertEqual(ds,tob,'-nan_equal');
            assertTrue(isempty(cuts));
            assertTrue(isempty(figh));
            assertTrue(isempty(axh));
            assertTrue(isempty(plh));
        end

        function test_spaghetti_set_labels(obj)
            tob = [obj.IX_data{2};obj.IX_data{2}*2;obj.IX_data{2}*0.5];
            [ds,cuts,figh,axh,plh] = spaghetti_plot(tob,'lab',{'A','B','C','D'});
            assertEqual(ds,tob,'-nan_equal');
            assertTrue(isempty(cuts));
            assertTrue(isa(figh,'matlab.ui.Figure'));
            assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
            assertTrue(isa(plh,'matlab.graphics.primitive.Patch'))
            assertEqual(numel(figh),1)
            assertEqual(numel(axh),1)
            assertEqual(numel(plh),3)
            assertEqual(axh.XTickLabel,{'A';'B';'C';'D'});
            close(figh);
        end

        function test_spaghetti_default_labels(obj)
            tob = [obj.IX_data{2};obj.IX_data{2}*2;obj.IX_data{2}*0.5];
            [ds,cuts,figh,axh,plh] = spaghetti_plot(tob);
            assertEqual(ds,tob,'-nan_equal');
            assertTrue(isempty(cuts));
            assertTrue(isa(figh,'matlab.ui.Figure'));
            assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
            assertTrue(isa(plh,'matlab.graphics.primitive.Patch'))
            assertEqual(numel(figh),1)
            assertEqual(numel(axh),1)
            assertEqual(numel(plh),3)
            assertEqual(axh.XTickLabel{1},tob(1).title{1});
            assertEqual(axh.XTickLabel{2},tob(2).title{1});
            assertEqual(axh.XTickLabel{3},tob(3).title{1});
            close(figh);
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

                [objh,axh,plh]  = meth(IXd3d_obj);
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
        function test_IXd2d_plot2D_methods_work_on_array(obj)
            dat2 = obj.IX_data{2};
            dat2.x = dat2.x+dat2.x(end);
            IXd2d_arr = [obj.IX_data{2},2*dat2];
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];
            need_fig = [false(numel(tstd.dnd_methods),1);tstd.overplot_requested(:)];

            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                if need_fig(i)
                    figure;
                end
                [objh,axh,plh] = meth(IXd2d_arr);

                assertEqual(numel(objh),1)
                assertEqual(numel(axh),1)
                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

                close(objh);
            end

        end

        function test_IXd2d_plot2D_methods_work(obj)
            IXd2d_obj = obj.IX_data{2};
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(IXd2d_obj);
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
        function test_IX2d_overplot_methods_work_together(obj)
            IX2d_obj = obj.IX_data{2};
            tstd = obj.interface_tester;

            opl_methods  = tstd.d2d_methods(tstd.d2d_overplot);
            fh = da(IX2d_obj);
            for i=1:numel(opl_methods(1:2))

                meth = opl_methods{i};

                [objh,axh,plh] = meth(IX2d_obj);

                assertEqual(numel(objh),1);
                assertEqual(numel(axh),1);
                assertTrue(numel(plh)==i+1);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));
            end
            assertTrue(isequal(fh,objh));
            close(objh);

            for i=1:numel(opl_methods(3:end))

                meth = opl_methods{2+i};

                [objh,axh,plh] = meth(IX2d_obj);

                assertEqual(numel(objh),1);
                assertEqual(numel(axh),1);
                assertTrue(numel(plh)==i);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));
            end
            close(objh);

        end
        %------------------------------------------------------------------
        function test_IX1d_plot1D_all_types_on_array(obj)
            all_types = get_global_var('genieplot','marker_types');
            n_types = numel(all_types);
            IX1d_arr = repmat(obj.IX_data{1},1,n_types+2);
            [objh,axh,plh] = dp(IX1d_arr);

            assertEqual(numel(objh),1);
            assertEqual(numel(axh),1);
            assertEqual(numel(plh),n_types+2);
            assertTrue(isa(objh,'matlab.ui.Figure'));
            assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
            assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

            close(objh);
        end

        function test_IX1d_plot1D_all_colour_on_array(obj)
            all_col = get_global_var('genieplot','colors');
            n_colours = numel(all_col);
            IX1d_arr = repmat(obj.IX_data{1},1,n_colours+2);
            [objh,axh,plh] = pl(IX1d_arr);

            assertEqual(numel(objh),1);
            assertEqual(numel(axh),1);
            assertEqual(numel(plh),n_colours+2);
            assertTrue(isa(objh,'matlab.ui.Figure'));
            assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
            assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

            close(objh);
        end

        function test_IX1d_plot1D_line_cycles_on_array(obj)
            % there are 4 line styles defined. 5th line has the same line
            % style as the first one
            IX1d_arr = [obj.IX_data{1},1.1*obj.IX_data{1},...
                1.2*obj.IX_data{1},1.3*obj.IX_data{1},1.4*obj.IX_data{1}];
            [objh,axh,plh] = pl(IX1d_arr);

            assertEqual(numel(objh),1);
            assertEqual(numel(axh),1);
            assertEqual(numel(plh),5);
            assertTrue(isa(objh,'matlab.ui.Figure'));
            assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
            assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

            assertEqual(plh(1).LineStyle,plh(5).LineStyle)
            close(objh);
        end

        function test_IX1d_overplot2_work_with_overlpot1(obj)
            IX1d_arr = [obj.IX_data{1},2*obj.IX_data{1}];

            [objh,axh,plh] = pl(IX1d_arr);
            assertTrue(isa(objh,'matlab.ui.Figure'));
            assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
            assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

            [objh,axh,plh] = pd(3*obj.IX_data{1});
            assertEqual(numel(objh),1);
            assertEqual(numel(axh),1);
            assertEqual(numel(plh),3);
            close(objh);
        end

        function test_IX1d_all_methods_work_together_on_array(obj)
            IX1d_arr = [obj.IX_data{1},2*obj.IX_data{1}];
            tstd = obj.interface_tester;

            pl_methods    = tstd.d1d_methods;
            is_plot       = ~tstd.d1d_overplot;

            for i=1:numel(pl_methods)

                meth = pl_methods{i};

                [objh,axh,plh] = meth(IX1d_arr);
                assertEqual(numel(objh),1);
                assertEqual(numel(axh),1);
                if is_plot(i)
                    assertTrue(numel(plh)==2);
                else
                end

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));
            end
            close(objh);
        end

        function test_IX1d_overplot_methods_work_together(obj)
            IX1d_obj = obj.IX_data{1};
            tstd = obj.interface_tester;

            opl_base    = tstd.d1d_methods(tstd.d1d_overplot);
            opl_methods = [opl_base(:);tstd.d1d_mthods_oveplot(:)];
            fh = dd(IX1d_obj);
            for i=1:numel(opl_methods)

                meth = opl_methods{i};

                [objh,axh,plh] = meth(IX1d_obj*(1+0.1*i));

                assertEqual(numel(objh),1);
                assertEqual(numel(axh),1);
                assertTrue(numel(plh)==i+1);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));
            end
            assertTrue(isequal(fh,objh));
            close(objh);
        end

        function test_IX1d_overplot1D_methods_work_on_array(obj)
            IX1d_arr = [obj.IX_data{1},2*obj.IX_data{1}];
            tstd = obj.interface_tester;


            opl_methods = tstd.d1d_mthods_oveplot;
            for i=1:numel(opl_methods)
                figure;
                meth = opl_methods{i};

                [objh,axh,plh] = meth(IX1d_arr);

                assertEqual(numel(objh),1);
                assertEqual(numel(axh),1);
                assertEqual(numel(plh),2);

                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

                close(objh);
            end

        end

        function test_IX1d_plot1D_methods_work_on_array(obj)
            IX1d_arr = [obj.IX_data{1},2*obj.IX_data{1}];
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:)];

            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(IX1d_arr);
                assertEqual(numel(objh),1);
                assertEqual(numel(axh),1);
                assertEqual(numel(plh),2);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));

                close(objh);
            end
        end

        function test_IX1d_plot1D_methods_work(obj)
            IX1d_obj = obj.IX_data{1};
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d1d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(IX1d_obj);
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

                [oboh,axh,plh] = meth(IX1d_obj);
                assertEqual(oboh,objh)
                assertTrue(numel(plh)>1);
                assertTrue(isa(objh,'matlab.ui.Figure'));
                assertTrue(isa(axh,'matlab.graphics.axis.Axes'));
                assertTrue(isa(plh,'matlab.graphics.primitive.Data'));
            end
            close(oboh);
        end
    end
end
