classdef data_plot_interface_tester < data_plot_interface
    % Class used in testing data_plot_interface, providing a concrete
    % implementation of the abstract class necessary to test the plot interface.
    %
    % In addition to that, it specifies lists of plot functions to test
    % grouped by the dimensionality of the plot, new plot or overplot, to enable 
    % comprehensive testing of common behaviour for all clases that inherit the
    % common interface data_plot_interface_tester, i.e. sqw, dnd and IX_dataset
    % classes.

    properties(Constant)
        % Methods for any of 1D, 2D and 3D data:
        methodsND_plot = {@plot}
        methodsND_plotOver = {@plotover}
        %dnd_overplot = [false,true];
        
        % Methods for 1D data:
        methods1D_plot = {@dd,@de,@dh,@dl,@dm,@dp};
        methods1D_plotOver = {@pd,@pe,@pl,@ph,@pm,@pp};
        methods1D_plotOverCurr = {@pdoc,@peoc,@phoc,@ploc,@pmoc,@ppoc}
        %d1d_overplot = [false(1,6),true(1,6)];
        
        % Methods for 2D data:
        methods2D_plot = {@da,@ds,@ds2}
        methods2D_plotOver = {@pa,@ps,@ps2};
        methods2D_plotOverCurr = {@paoc,@psoc,@ps2oc};
%         overplot_requested = [false,false,false,...
%             false,true,false,false,true,true];
%         d2d_overplot = [false(1,3),true(1,6)];

        % Methods for 3D data:
        methods3D_plot = {@sliceomatic,@sliceomatic_overview};
        
        
        
        %--- old: ******************************************************
        dnd_methods = {@plot,@plotover}
        dnd_overplot = [false,true];

        d1d_methods = {@dd,@de,@dh,@dl,@dm,@dp,...
            @pd,@pe,@pl,@ph,@pm,@pp}
        d1d_overplot = [false(1,6),true(1,6)];
        d1d_mthods_oveplot = {@pdoc,@peoc,@phoc,@ploc,@pmoc,@ppoc}
        
        
        % Methods for 2D data:
        d2d_methods = {@da,@ds,@ds2,...
            @pa,@paoc,@ps,@ps2,@psoc,@ps2oc};
        overplot_requested = [false,false,false,...
            false,true,false,false,true,true];
        d2d_overplot = [false(1,3),true(1,6)];

        % Methods for 3D data:
        d3d_methods = {@sliceomatic,@sliceomatic_overview};
    end
    
    properties
        ndim;
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = data_plot_interface_tester()
            % Concrete implementation of minimal class to test the abstract
            % data_plot_interface class
            obj.ndim = 2;   % dummy value - will not be used
        end

        function nd = dimensions(obj)
            % Concrete implementation of the dimensions class that is required
            % by data_plot_interface
            nd = obj.ndim;
        end
    end
end
