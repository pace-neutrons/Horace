classdef pTestPerformanceTester < TestPerformance
    % Tester class to help validating perfromance testing utilities.
    
    methods
        function obj = pTestPerformanceTester(varargin)
            if nargin > 0
                argi = {'pTestPerformanceTester',varargin{1}};
            else
                argi = {'pTestPerformanceTester',...
                    TestPerformance.default_PerfTest_fname(mfilename('fullpath'))};
            end
            
            obj = obj@TestPerformance(argi{:});
            obj.tests_available_ = {'some_gen_sqw','some_cut','gen_sqw'};
        end
    end
end
