classdef data_plot_interface_tester < data_plot_interface
    % Class used in tesing data_plot_interface, providing real
    % implementation of abstract class, necessary to test plot interface
    %
    % In addition to that, it specifies the list of plot functions to test
    % in particular tests, common for all test clases, i.e. sqw, dnd and
    % IX_dataset classes, which have common interface.

    properties(Constant)
        dnd_methods = {@plot,@plotover}
        dnd_overplot = [false,true];
        d1d_methods = {@dd,@de,@dh,@dl,@dm,@dp,...
            @pd,@pe,@pl,@ph,@pm,@pp}
        d1d_overplot = [false(1,6),true(1,6)];

        % overlpot only methods
        d1d_mthods_oveplot = { @pdoc,@peoc,@phoc,@ploc,@pmoc,@ppoc}
        d2d_methods = {@da,@ds,@ds2,...
            @pa,@paoc,@ps,@ps2,@ps2oc,@psoc};
        overplot_requested = [false,false,false,...
            false,true,false,false,true,true];
        d2d_overplot = [false(1,3),true(1,6)];
        d3d_methods = {@sliceomatic,@sliceomatic_overview};
    end
    properties
        ndim;
    end

    methods
        % define dimension functions (abstract in base class) to allow
        % data_plot_interface implementation.
        % The dimensions would not be used in any calculations
        function nd = dimensions(obj)
            nd = obj.ndim;
        end
        function obj = data_plot_interface_tester()
            obj.ndim = 2;
        end

    end
end