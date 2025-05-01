classdef AxesBlockBase_tester < AxesBlockBase
    %AxesBlockBase_tester helper class to allow to test some methods 
    % of abstract AxesBlockBase class
    %
    methods
        function obj = AxesBlockBase_tester(varargin)
            %AxesBlockBase_tester Construct an instance of this class
            obj = obj@AxesBlockBase(varargin{:});
        end

        function varargout = data_plot_titles(~)
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'method data_plot_titles is not implemented')
        end
    end
    methods(Access=protected)
        function  pbin = default_pbin(~)
            % defines bins used when default constructor with dimensions only is called.
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'method default_pbin is not implemented')

        end
        function volume = calc_bin_volume(~)
            % calculate bin volume from the  axes of the axes block or input
            % axis organized in cellarray of 4 axis.
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'method calc_bin_volume is not implemented')

        end
        function vol_scale = get_volume_scale(~)
            % retrieve the bin volume scale so that any bin volume be expessed in
            % A^-3*mEv
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'method get_volume_scale is not implemented')
        end
    end
    %----------------------------------------------------------------------
    % Serializable interface
    methods(Access=public)
        function ver = classVersion(~)
            ver = 1;
        end
    end
end
