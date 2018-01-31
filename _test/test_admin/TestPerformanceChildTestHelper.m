classdef TestPerformanceChildTestHelper < TestPerformance
    % This class is the class-helper to test inheritance for
    % TestPerformance class
    
    
    properties
        
    end
    
    methods
        function obj = TestPerformanceChildTestHelper(varargin)
            if nargin > 0
                argi = varargin;
            else
                argi = {'TestPerformanceChildTestHelper',...
                    TestPerformance.default_PerfTest_fname(mfilename('fullpath'))...
                    };
            end
            obj = obj@TestPerformance(argi{:});
        end
        
        function fake_test_method(obj)
            %
            %   Detailed explanation goes here
            time = tic();
            sum = 0;
            for i=1:100
                sum = sum+i;
            end
            obj.assertPerformance(time,'fake_test_operations',...
                'this is not a performance test itself but the test of performance test inheritance operational',...
                true);
        end
    end
end

