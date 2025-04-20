classdef test_plot_sqw < TestCase
    % Test plotting methods on sqw and dnd objects
    properties
        data1D
        data2D
        data3D
        data4D
        interface_tester = data_plot_interface_tester();
    end

    methods
        function obj = test_plot_sqw(varargin)
            obj = obj@TestCase('test_plot_sqw');
            
            % Load example 1D, 2D, 3D, 4D sqw objects
            hp = horace_paths().test_common;    % common data location

            sqw_1d_file = fullfile(hp, 'sqw_1d_1.sqw');
            sqw_2d_file = fullfile(hp, 'sqw_2d_1.sqw');
            sqw_3d_file = fullfile(hp, 'w3d_sqw.sqw');
            sqw_4d_file = fullfile(hp, 'sqw_4d.sqw');
            
            obj.data1D = read_sqw(sqw_1d_file);
            obj.data2D = read_sqw(sqw_2d_file);
            obj.data3D = read_sqw(sqw_3d_file);   
            obj.data4D = read_sqw(sqw_4d_file);           
        end


        %------------------------------------------------------------------
        % Four-dimensional data
        %------------------------------------------------------------------
        function test_sqw4D_all_plot_methods_throw(obj)
            % Test all 1D, 2D, 3D plot methods throw an error
            cleanupObj = onCleanup(@clear_figures);
            
            T = obj.interface_tester;
            all_methods = [ ...
                T.methodsND_plot(:); T.methodsND_plotOver(:); ...
                T.methods1D_plot(:); T.methods1D_plotOver(:); ...
                T.methods1D_plotOverCurr(:); ...
                T.methods2D_plot(:); T.methods2D_plotOver(:); ...
                T.methods2D_plotOverCurr(:); ...
                T.methods3D_plot(:)];

            clear_figures()
            for i=1:numel(all_methods)
                assertExceptionThrown(...
                    @()function_caller(all_methods{i}, obj.data4D), ...
                    'HORACE:graphics:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(all_methods{i})));
            end
        end
        
        
        %------------------------------------------------------------------
        % Three-dimensional data
        %------------------------------------------------------------------
        function test_sqw3D_plot3D_methods_work(obj)
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
        function test_sqw3D_other_plot_methods_throw(obj)
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
                    'HORACE:graphics:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        
        %------------------------------------------------------------------
        function test_sqw3D_plot3D_methods_do_not_work_with_array(obj)
            % Test that all 3D 'plot' methods do not plot arrays of data
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods3D_plot(:)];
            data3D_arr = [obj.data3D, 2*obj.data3D];

            clear_figures()
            for i=1:numel(methods)
                assertExceptionThrown(...
                    @()function_caller(methods{i}, data3D_arr), ...
                    'HORACE:graphics:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(methods{i})));
            end
        end
        
        
        %------------------------------------------------------------------
        % Two-dimensional data
        %------------------------------------------------------------------
        function test_sqw2D_plot2D_methods_work(obj)
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
        function test_sqw2D_other_plot_methods_throw(obj)
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
                    'HORACE:graphics:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        
        %------------------------------------------------------------------
        function test_sqw2D_plot2D_methods_work_with_array(obj)
            % Test that all 2D 'plot' methods plot arrays of data
            % That is methods like da, ds,... ('plot') that make fresh figures
            cleanupObj = onCleanup(@clear_figures);

            T = obj.interface_tester;
            methods = [T.methodsND_plot(:); T.methods2D_plot(:)];
            data2D_arr = [obj.data2D, 2*obj.data2D];

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
        % One-dimensional plot methods
        %------------------------------------------------------------------
        function test_sqw1D_all_plot1D_methods_work(obj)
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
        function test_sqw1D_other_plot_methods_throw(obj)
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
                    'HORACE:graphics:invalid_argument', ...
                    sprintf('error for method number %d: %s',i, ...
                    func2str(other_methods{i})));
            end
        end
        
        %------------------------------------------------------------------
        function test_sqw1D_plot1D_methods_work_with_array(obj)
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
