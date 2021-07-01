classdef test_progress_herbert< check_progress_common_methods
    % Helper class to test herbert cluster progress
    %
    methods
        %
        function obj=test_progress_herbert(varargin)
            ci = ClusterHerbertStateTester();
            obj = obj@check_progress_common_methods(ci,varargin{:});
        end
        %
    end
end
