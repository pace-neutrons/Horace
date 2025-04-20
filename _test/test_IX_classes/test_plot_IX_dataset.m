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
        end
        
        
        %------------------------------------------------------------------
        % Spaghetti_plot tests
        %------------------------------------------------------------------
        function test_spaghetti_plot_noplot(obj)
            cleanupObj = onCleanup(@clear_figures);
            %
            wdisp = [obj.data2D, obj.data2D*2, obj.data2D*0.5];
            [wdisp_out, cuts, fig_h, axes_h, plot_h] = spaghetti_plot(wdisp, 'noplot');
            assertEqual(wdisp_out, wdisp, '-nan_equal');
            assertTrue(isempty(cuts));
            assertTrue(isempty(fig_h));
            assertTrue(isempty(axes_h));
            assertTrue(isempty(plot_h));
        end

        function test_spaghetti_plot_set_labels(obj)
            cleanupObj = onCleanup(@clear_figures);
            %
            wdisp = [obj.data2D, obj.data2D*2, obj.data2D*0.5];
            [wdisp_out, cuts, fig_h, axes_h, plot_h] = spaghetti_plot(wdisp,...
                'lab', {'A','B','C','D'});
            assertEqual(wdisp_out, wdisp, '-nan_equal');
            assertTrue(isempty(cuts));
            assertTrue(isa(fig_h, 'matlab.ui.Figure'));
            assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
            assertTrue(isa(plot_h, 'matlab.graphics.primitive.Patch'))
            assertEqual(numel(fig_h), 1)
            assertEqual(numel(axes_h), 1)
            assertEqual(numel(plot_h), 3)
            assertEqual(axes_h.XTickLabel,{'A';'B';'C';'D'});
        end

        function test_spaghetti_plot_default_labels(obj)
            cleanupObj = onCleanup(@clear_figures);
            %
            wdisp = [obj.data2D, obj.data2D*2, obj.data2D*0.5];
            [wdisp_out,cuts,fig_h,axes_h,plot_h] = spaghetti_plot(wdisp);
            assertEqual(wdisp_out, wdisp, '-nan_equal');
            assertTrue(isempty(cuts));
            assertTrue(isa(fig_h,'matlab.ui.Figure'));
            assertTrue(isa(axes_h,'matlab.graphics.axis.Axes'));
            assertTrue(isa(plot_h,'matlab.graphics.primitive.Patch'))
            assertEqual(numel(fig_h),1)
            assertEqual(numel(axes_h),1)
            assertEqual(numel(plot_h),3)
            assertEqual(axes_h.XTickLabel{1},wdisp(1).title{1});
            assertEqual(axes_h.XTickLabel{2},wdisp(2).title{1});
            assertEqual(axes_h.XTickLabel{3},wdisp(3).title{1});
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
        function test_IX3D_plot3D_methods_do_not_work_with_array(obj)
            % Test that all 3D 'plot' methods do not plot arrays of data
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods3D_plot(:)];
            data3D_shift = obj.data3D;
            data3D_shift.x = data3D_shift.x + obj.data2D.x(end);
            data3D_shift.y = data3D_shift.y + 0.3*obj.data2D.y(end);
            data3D_arr = [obj.data3D, data3D_shift];

            clear_figures()
            for i=1:numel(methods)
                assertExceptionThrown(...
                    @()function_caller(methods{i}, data3D_arr), ...
                    'HERBERT:IX_dataset_3d:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(methods{i})));
            end
        end

        
        %------------------------------------------------------------------
        % Two-dimensional data
        %------------------------------------------------------------------
        function test_IX2D_plot2D_methods_work(obj)
            % Test all 2D plot methods produce a figure
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = [...
                T.methodsND_plot(:); T.methods2D_plot(:); ...
                T.methodsND_plotOver(:); T.methods2D_plotOver(:); ...
                T.methods2D_plotOverCurr(:)];
            
            clear_figures()
            for i=1:numel(methods)
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(obj.data2D);
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h, 'matlab.graphics.primitive.Data'));
            end
        end

        %------------------------------------------------------------------
        function test_IX2D_other_plot_methods_throw(obj)
            % Test all plot methods for 1D and 3D throw an error with 2D data
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            other_methods = [ ...
                T.methods1D_plot(:); T.methods1D_plotOver(:); ...
                T.methods1D_plotOverCurr(:); ...
                T.methods3D_plot(:)];

            clear_figures()
            for i=1:numel(other_methods)
                assertExceptionThrown(...
                    @()function_caller(other_methods{i}, obj.data2D), ...
                    'HORACE:IX_dataset_2d:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        
        %------------------------------------------------------------------
        function test_IX2D_plot2D_methods_reuseFig_newAxes(obj)
            % Test that all 2D 'plot' (as opposed to 'plot over' and 'plot over
            % curr') methods reuse a 2D figure, but erase the axes and plots
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods2D_plot(:)];

            data2D_shift = obj.data2D;
            data2D_shift.x = data2D_shift.x + obj.data2D.x(end);
            data2D_shift.y = data2D_shift.y + 0.3*obj.data2D.y(end);
            for i=1:numel(methods)
                clear_figures()
                meth = methods{i};
                % Plot figure and get handles
                [fig_h_ref, axes_h_ref] = meth(obj.data2D);
                % Plot shifted dataset; the figure should be reused, but the
                % axes will be different as the dataset has been shifted.
                [fig_h, axes_h] = meth(data2D_shift);

                assertTrue(isequal(fig_h, fig_h_ref));
                assertFalse(isequal(axes_h, axes_h_ref));
            end
        end
        
        %------------------------------------------------------------------
        function test_IX2D_plotOver2D_methods_reuseFigAndAxes(obj)
            % Test that all 2D 'plot over' (as opposed to 'plot' and 'plot over
            % current') methods add plots to a 2D figure
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods2D_plot(:)];
            methods_over = [T.methodsND_plotOver(:); T.methods2D_plotOver(:)];

            % Clear, plot then overplot (method{i} and method_over{i} have the
            % same type ('area' or 'surface'), so there should be an overplot
            % and not creation of a new window.
            data2D_shift = obj.data2D;
            data2D_shift.x = data2D_shift.x + obj.data2D.x(end);
            data2D_shift.y = data2D_shift.y + 0.3*obj.data2D.y(end);
            for i=1:numel(methods)
                clear_figures()
                % Create figure on which to overplot:
                meth = methods{i};
                [fig_h_ref, axes_h_ref, plot_h_ref] = meth(obj.data2D);
                % Now overplot
                meth = methods_over{i};
                [fig_h, axes_h, plot_h] = meth(data2D_shift);
                
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));

                assertTrue(fig_h==fig_h_ref);
                assertTrue(axes_h==axes_h_ref); % handle objects, hence equality
                assertTrue(numel(plot_h) == numel(plot_h_ref) + 1);
            end
        end
        
        %------------------------------------------------------------------
        function test_IX2D_plotOverCurr2D_methods_work(obj)
            % Test that all 2D 'plot over current' add to any current figure
            % regardless of the type of figure
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = T.methods2D_plotOverCurr(:);

            % Create a figure on which to overplot, and get the figure, axes and
            % plot handles:
            plot_h_prev = surf(obj.data2D.x(1:end-1), obj.data2D.y(1:end-1), ...
                obj.data2D.signal');
            fig_h_prev = gcf;
            axes_h_prev = gca;
            
            % Succesively overplot
            data2D_shift = obj.data2D;
            for i=1:numel(methods)
                data2D_shift.x = data2D_shift.x + obj.data2D.x(end);
                data2D_shift.y = data2D_shift.y + 0.3*obj.data2D.y(end);
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth((1+i)*data2D_shift);
                all_fig_h = findobj(groot,'Type','Figure');
                assertTrue(numel(all_fig_h)==1,'Did not overplot only')
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
        function test_IX2D_plot2D_methods_work_with_array(obj)
            % Test that all 2D 'plot' methods plot arrays of data
            % That is methods like da, ds,... ('plot') that make fresh figures
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods2D_plot(:)];
            data2D_shift = obj.data2D;
            data2D_shift.x = data2D_shift.x + obj.data2D.x(end);
            data2D_shift.y = data2D_shift.y + 0.3*obj.data2D.y(end);
            data2D_arr = [obj.data2D, data2D_shift];

            for i=1:numel(methods)
                clear_figures()
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth(data2D_arr);
                all_fig_h = findobj(groot,'Type','Figure');
                assertTrue(numel(all_fig_h)==1,'Did not overplot only')
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
                assertEqual(numel(fig_h),1);
                assertEqual(numel(axes_h),1);
                assertEqual(numel(plot_h),2);
            end
        end
        
        %------------------------------------------------------------------
        function test_IX2D_plotOver2D_methods_work_with_array(obj)
            % Test that all 2D 'plot over' methods plot arrays of data
            % That is methods like pa, ps,... ('plot over')
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods2D_plot(:)];
            methods_over = [T.methodsND_plotOver(:); T.methods2D_plotOver(:)];

            % Clear, plot then overplot (method{i} and method_over{i} have the
            % same type ('area' or 'surface'), so there should be an overplot
            % and not creation of a new window.
            data2D_shift = obj.data2D;
            data2D_shift.x = data2D_shift.x + obj.data2D.x(end);
            data2D_shift.y = data2D_shift.y + 0.3*obj.data2D.y(end);
            data2D_arr = [obj.data2D, data2D_shift];
            
            data2D_arr_shift = data2D_arr;
            data2D_arr_shift(1).x = data2D_arr_shift(1).x + obj.data2D.x(end);
            data2D_arr_shift(1).y = data2D_arr_shift(1).y + obj.data2D.y(end);
            data2D_arr_shift(2).x = data2D_arr_shift(2).x + obj.data2D.x(end);
            data2D_arr_shift(2).y = data2D_arr_shift(2).y + obj.data2D.y(end);
            for i=1:numel(methods)
                clear_figures()
                % Create figure on which to overplot:
                meth = methods{i};
                [fig_h_ref, axes_h_ref, plot_h_ref] = meth(data2D_arr);
                % Now overplot
                meth = methods_over{i};
                [fig_h, axes_h, plot_h] = meth(data2D_arr_shift);
                
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
                assertTrue(numel(plot_h_ref) == 2);

                assertTrue(fig_h==fig_h_ref);
                assertTrue(axes_h==axes_h_ref); % handle objects, hence equality
                assertTrue(numel(plot_h) == numel(plot_h_ref) + 2);
            end
        end
        
        %------------------------------------------------------------------
        function test_IX2D_plotOverCurr2D_methods_work_with_array(obj)
            % Test that all 2D 'plot over current' methods plot arrays of data
            % That is methods like paoc, psoc,... ('plot over current')
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            methods = T.methods2D_plotOverCurr(:);
            
            % Create a figure on which to overplot, and get the figure, axes and
            % plot handles:
            plot_h_prev = surf(obj.data2D.x(1:end-1), obj.data2D.y(1:end-1), ...
                obj.data2D.signal');
            fig_h_prev = gcf;
            axes_h_prev = gca;
            
            % Succesively overplot
            data2D_arr_shift = [obj.data2D, obj.data2D];
            data2D_arr_shift(1).x = data2D_arr_shift(1).x + obj.data2D.x(end);
            data2D_arr_shift(1).y = data2D_arr_shift(1).y + 0.3*obj.data2D.y(end);
            data2D_arr_shift(2).x = data2D_arr_shift(1).x + obj.data2D.x(end);
            data2D_arr_shift(2).y = data2D_arr_shift(1).y + 0.3*obj.data2D.y(end);
            for i=1:numel(methods)
                data2D_arr_shift(1).y = data2D_arr_shift(1).y + obj.data2D.y(end);
                data2D_arr_shift(2).y = data2D_arr_shift(2).y + obj.data2D.y(end);
                meth = methods{i};
                [fig_h, axes_h, plot_h] = meth((1+i)*data2D_arr_shift);
                all_fig_h = findobj(groot,'Type','Figure');
                assertTrue(numel(all_fig_h)==1,'Did not overplot only')
                assertTrue(isa(fig_h, 'matlab.ui.Figure'));
                assertTrue(isa(axes_h, 'matlab.graphics.axis.Axes'));
                assertTrue(isa(plot_h,'matlab.graphics.primitive.Data'));
                
                assertTrue(fig_h==fig_h_prev);
                assertTrue(axes_h==axes_h_prev); % handle objects, hence equality
                assertTrue(numel(plot_h) == numel(plot_h_prev) + 2);
                
                fig_h_prev = fig_h;
                axes_h_prev = axes_h;
                plot_h_prev = plot_h;
            end
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
                all_fig_h = findobj(groot,'Type','Figure');
                assertTrue(numel(all_fig_h)==1,'Did not overplot only')
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
        % Interface test
        %------------------------------------------------------------------
        function test_plotInterface_throws(obj)
            % 2025-04-18: Refactoring of a test of unclear purpose.
            % It seems to test that the plot methods are not valid with a
            % concrete implementation of the data_plot_interface abstract class.
            % Presumably there was an error that was created during development
            % that this test was created to capture.
            % Originally in a test suite in the folder testing dnd objects, now
            % moved to a test suite for the IX_dataset_*d class as it in fact makes
            % no reference to dnd or sqw objects, whereas IX_dataset_*d underpin
            % the implementation of plot methods.
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            all_methods = [ ...
                T.methodsND_plot(:); T.methodsND_plotOver(:); ...
                T.methods1D_plot(:); T.methods1D_plotOver(:); ...
                T.methods1D_plotOverCurr(:); ...
                T.methods2D_plot(:); T.methods2D_plotOver(:); ...
                T.methods2D_plotOverCurr(:); ...
                T.methods3D_plot(:)];
            
            for i=1:numel(all_methods)
                assertExceptionThrown(...
                    @()function_caller(all_methods{i}, T), ...
                    'HORACE:data_plot_interface_tester:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(all_methods{i})));
            end
        %------------------------------------------------------------------
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
