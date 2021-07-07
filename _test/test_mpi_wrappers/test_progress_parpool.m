classdef test_progress_parpool< check_progress_common_methods
    % Helper class to test parpool progress 
    %
    methods
        %
        function obj=test_progress_parpool(varargin)
            ci = ClusterParpoolStateTester();
            obj = obj@check_progress_common_methods(ci,varargin{:});
        end
        %
    end
end


