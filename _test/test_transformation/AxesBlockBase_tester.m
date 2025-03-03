classdef AxesBlockBase_tester < AxesBlockBase
    %AxesBlockBase_tester helper class to allow to test some AxesBlockBase
    %methods


    methods
        function obj = AxesBlockBase_tester(varargin)
            %AxesBlockBase_tester Construct an instance of this class
            obj = obj@AxesBlockBase(varargin{:});
        end

        function varargout = data_plot_titles(~)
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'This method is not implemented')
        end
    end
    methods(Access=protected)
        function obj = check_and_set_img_range(~)
            % main setter for image range. Overloadable for different kind
            % of axes blocks.
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'This method is not implemented')
        end
        function  pbin = default_pbin(~)
            % defines bins used when default constructor with dimensions only is called.
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'This method is not implemented')

        end
        function volume = calc_bin_volume(~)
            % calculate bin volume from the  axes of the axes block or input
            % axis organized in cellarray of 4 axis.
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'This method is not implemented')

        end
        function vol_scale = get_volume_scale(~)
            % retrieve the bin volume scale so that any bin volume be expessed in
            % A^-3*mEv
            error('HORACE:AxesBlockBase_tester:not_implemented', ...
                'This method is not implemented')
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
