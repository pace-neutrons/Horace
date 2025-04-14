classdef test_plot_IX_dataset < TestCase
    % Test plotting of IX_dataset_1d, IX_dataset_2d and IX_dataset_3d objects
    %
    % The tests are for 
    % - the validity of 
    properties
        data1D
        data2D
        data3D
        interface_tester = data_plot_interface_tester();

        IX_data
    end

    methods
        function obj = test_plot_IX_dataset(varargin)
            obj = obj@TestCase('test_plot_IX_dataset');
            
            % Load example 1D, 2D, 3D, IX_dataset_*d objects
            hp = horace_paths().test_common;    % common data location

            sqw_1d_file = fullfile(hp, 'sqw_1d_1.sqw');
            sqw_2d_file = fullfile(hp, 'sqw_2d_1.sqw');
            sqw_3d_file = fullfile(hp, 'w3d_sqw.sqw');
            
            obj.data1D = IX_dataset_1d(read_dnd(sqw_1d_file));
            obj.data2D = IX_dataset_2d(read_dnd(sqw_2d_file));
            obj.data3D = IX_dataset_3d(read_dnd(sqw_3d_file));           
            
            %---- old:
            obj.IX_data = {obj.data1D; obj.data2D; obj.data3D};

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
        % Three-dimensional data
        %------------------------------------------------------------------
        function test_IX3D_plot3D_methods_work(obj)
            % Test all 3D plot methods produce a figure
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods3D_plot(:)];
            
            clear_figures()
            for i=1:numel(methods)
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(obj.data3D);
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isstruct(plot_h));
                if i>1  % Must have cleared existing figure window and reused it
                    assertTrue(fig_h==fig_h_ref);
                else    
                    fig_h_ref = fig_h;  % store fig handle first time through loop
                end
            end
        end

        %------------------------------------------------------------------
        function test_IX3D_other_plot_methods_throw(obj)
            % Test all plot methods for 1D and 2D throw an error with 3D data
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            other_methods = [ ...
                T.methods1D_plot(:); T.methods1D_plotOver(:); ...
                T.methods1D_plotOverCurr(:); ...
                T.methods2D_plot(:); T.methods2D_plotOver(:); ...
                T.methods2D_plotOverCurr(:)];

            clear_figures()
            for i=1:numel(other_methods)
                assertExceptionThrown(...
                    @()function_caller(other_methods{i}, obj.data3D), ...
                    'HORACE:IX_dataset_3d:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end

        %------------------------------------------------------------------
        % Two-dimensional data
        %------------------------------------------------------------------
        function test_IX2D_plot2D_methods_work(obj)
            tstd = obj.interface_tester;
            pl_methods = [tstd.dnd_methods(:);tstd.d2d_methods(:)];

            prev_h = [];
            for i=1:numel(pl_methods)
                meth = pl_methods{i};

                [objh,axh,plh] = meth(obj.data2D);
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
        function test_IX2D_other_plot_methods_throw(obj)
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
        function test_IX2D_plot2D_methods_work_on_array(obj)
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

        function test_IX2D_overplot_methods_work_together(obj)
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
        % One-dimensional plot methods
        %------------------------------------------------------------------
        function test_IX1D_all_plot1D_methods_work(obj)
            % Test that all 1D methods produce a figure
            % Methods like dl, dm,... ('plot') that make fresh figures
            % Methods like pl, pm,... ('plot over') make fresh figures if none exist
            % Methods like ploc, pmoc,... ('plot over current') make fresh figures if none exist
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = [...
                T.methodsND_plot(:); T.methods1D_plot(:); ...
                T.methodsND_plotOver(:); T.methods1D_plotOver(:); ...
                T.methods1D_plotOverCurr(:)];

            for i=1:numel(methods)
                clear_figures()
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(obj.data1D);
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
            end
        end
        
        %------------------------------------------------------------------
        function test_IX1D_other_plot_methods_throw(obj)
            % Test all plot methods for 2D and 3D throw an error with 1D data
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            other_methods = [ ...
                T.methods2D_plot(:); T.methods2D_plotOver(:); ...
                T.methods2D_plotOverCurr(:); ...
                T.methods3D_plot(:)];
            
            clear_figures()
            for i=1:numel(other_methods)
                assertExceptionThrown(...
                    @()function_caller(other_methods{i}, obj.data1D), ...
                    'HORACE:IX_dataset_1d:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        
        %------------------------------------------------------------------
        function test_IX1D_plot1D_methods_reuseFig_newAxes(obj)
            % Test that all 1D 'plot' (as opposed to 'plot over' and 'plot over
            % curr') methods reuse a 1D figure, but erase the axes and plots
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods1D_plot(:)];

            for i=1:numel(methods)
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(obj.data1D);
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
                if i>1  % Must have cleared existing figure window and reused it
                    assertTrue(fig_h==fig_h_prev);
                    assertFalse(all(isgraphics(axes_h_prev(:))));
                    assertFalse(all(isgraphics(plot_h_prev(:))));
                end
                fig_h_prev = fig_h;
                axes_h_prev = axes_h;
                plot_h_prev = plot_h;
            end
        end
        
        %------------------------------------------------------------------
        function test_IX1D_plotOver1D_methods_reuseFigAndAxes(obj)
            % Test that all 1D 'plot over' (as opposed to 'plot' and 'plot over
            % current') methods add plots to a 1D figure
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = [T.methodsND_plotOver(:); T.methods1D_plotOver(:)];

            % Create figure on which to overplot:
            [fig_h_prev, axes_h_prev, plot_h_prev] = plot(obj.data1D);
            
            % Succesively overplot
            for i=1:numel(methods)
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth((1+i)*obj.data1D);
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));

                assertTrue(fig_h==fig_h_prev);
                assertTrue(axes_h==axes_h_prev); % handle objects, hence equality
                assertTrue(numel(plot_h) == numel(plot_h_prev) + 1);
                
                fig_h_prev = fig_h;
                axes_h_prev = axes_h;
                plot_h_prev = plot_h;
            end
        end
        
        %------------------------------------------------------------------
        function test_IX1D_plotOverCurr1D_methods_work(obj)
            % Test that all 1D 'plot over current' add to any current figure
            % regardless of the type of figure
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = T.methods1D_plotOverCurr(:);

            % Create a figure on which to overplot, and get the figure, axes and
            % plot handles:
            plot_h_prev = plot([0,0.1],[1e4,2e4]);
            fig_h_prev = gcf;
            axes_h_prev = gca;
            
            % Succesively overplot
            for i=1:numel(methods)
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth((1+i)*obj.data1D);
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));

                assertTrue(fig_h==fig_h_prev);
                assertTrue(axes_h==axes_h_prev); % handle objects, hence equality
                assertTrue(numel(plot_h) == numel(plot_h_prev) + 1);
                
                fig_h_prev = fig_h;
                axes_h_prev = axes_h;
                plot_h_prev = plot_h;
            end
        end
        
        %------------------------------------------------------------------
        function test_IX1D_plot1D_methods_work_with_array(obj)
            % Test that all 1D 'plot' methods plot arrays of data
            % That is methods like dl, dm,... ('plot') that make fresh figures
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods1D_plot(:)];
            data1D_arr = [obj.data1D, 2*obj.data1D];

            for i=1:numel(methods)
                clear_figures()
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(data1D_arr);
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
                assertEqual(numel(fig_h),1);
                assertEqual(numel(axes_h),1);
                assertEqual(numel(plot_h),2);
            end
        end
        
        %------------------------------------------------------------------
        function test_IX1D_plotOver1D_methods_work_with_array(obj)
            % Test that all 1D 'plot over' methods plot arrays of data
            % That is methods like pl, pm,... ('plot over')
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = [T.methodsND_plotOver(:); T.methods1D_plotOver(:)];
            data1D_arr = [obj.data1D, 2*obj.data1D];
            
            for i=1:numel(methods)
                clear_figures()
                % Create figure on which to overplot:
                plot(0.5*obj.data1D);
                
                % Overplot
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(data1D_arr);
                
                all_fig_h = findobj(groot,'Type','Figure');
                assertTrue(numel(all_fig_h)==1,'Did not overplot only')
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
                assertEqual(numel(fig_h),1);
                assertEqual(numel(axes_h),1);
                assertEqual(numel(plot_h),3);   % original and two overplotted
            end
        end
        
        %------------------------------------------------------------------
        function test_IX1D_plotOverCurr1D_methods_work_with_array(obj)
            % Test that all 1D 'plot over current' methods plot arrays of data
            % That is methods like ploc, pmoc,... ('plot over current')
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = T.methods1D_plotOverCurr(:);
            data1D_arr = [obj.data1D, 2*obj.data1D];
            
            for i=1:numel(methods)
                clear_figures()
                % Create figure on which to overplot:
                plot([0,0.1],[1e4,2e4]);    % *not* a genie_figure
                
                % Overplot
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(data1D_arr);
                
                all_fig_h = findobj(groot,'Type','Figure');
                assertTrue(numel(all_fig_h)==1,'Did not overplot only')
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
                assertEqual(numel(fig_h),1);
                assertEqual(numel(axes_h),1);
                assertEqual(numel(plot_h),3);   % original and two overplotted
            end
        end
        
        

        
        
        
        %------------------------------------------------------------------
        function test_IX1D_plot1D_all_types_on_array(obj)
            all_types = genieplot.get('marker_types');
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

        function test_IX1D_plot1D_all_colour_on_array(obj)
            all_col = genieplot.get('colors');
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

        function test_IX1D_plot1D_line_cycles_on_array(obj)
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

        %================================
        function test_IX1D_overplot2_work_with_overlpot1(obj)
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

        function test_IX1D_all_methods_work_together_on_array(obj)
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

        function test_IX1D_overplot_methods_work_together(obj)
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





    end
end

%--------------------------------------------------------------------------
% Utility functions
%--------------------------------------------------------------------------
function clear_figures
% Delete all existing figures for a clean graphics test
fig_handles = findobj(0, 'Type', 'figure');
if ~isempty(fig_handles)
    delete(fig_handles)
end
end

%--------------------------------------------------------------------------
function function_caller(function_handle, varargin)
% Run a method or a function
% Wraps the method or function handle so that the call can be run as an argument
% in e.g. assertErrorThrown within a loop that loops over function handles
function_handle(varargin{:});
end
