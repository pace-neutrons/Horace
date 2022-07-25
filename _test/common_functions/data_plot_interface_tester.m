classdef data_plot_interface_tester < data_plot_interface
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here

    properties(Constant)
        dnd_methods = {@plot,@plotover}
        d1d_methods = {@dd,@de,@dh,@dl,@dm,@dp,...
            @pd,@pe,@ph,@pl,@pm,@pp}
        d1d_mthods_oveplot = {@pdoc,@peoc,@phoc,@ploc,@pmoc,@ppoc}
        d2d_methods = {@da,@ds,@ds2,...
            @pa,@paoc,@ps,@ps2,@ps2oc,@psoc};
        d3d_methods = {@sliceomatic,@sliceomatic_overview};
    end
    properties
        ndim;
    end

    methods
        function nd = dimensions(obj)
            nd = obj.ndim;
        end
        function obj = data_plot_interface_tester()
            obj.ndim = 2;
        end

    end
end