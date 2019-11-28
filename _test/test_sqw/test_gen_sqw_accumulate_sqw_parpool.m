classdef test_gen_sqw_accumulate_sqw_parpool <  ...
        gen_sqw_accumulate_sqw_tests_common & gen_sqw_common_config
    % Series of tests of gen_sqw and associated functions run on pool of
    % workers, provided by Matlab parallel computing toolbox.
    %
    %
    % Optionally writes results to output file to compare with previously
    % saved sample test results
    %---------------------------------------------------------------------
    % Usage:
    %
    %1) Normal usage:
    % Run all unit tests and compare their results with previously saved
    % results stored in test_gen_sqw_accumulate_sqw_output.mat file
    % located in the same folder as this function:
    %
    %>>runtests test_gen_sqw_accumulate_sqw_parpool
    %---------------------------------------------------------------------
    %2) Run particular test case from the suite:
    %
    %>>tc = test_gen_sqw_accumulate_sqw_parpool();
    %>>tc.test_[particular_test_name] e.g.:
    %>>tc.test_accumulate_sqw14();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_gen_sqw_accumulate_sqw_sep_session('save');
    %>>tc.save():
    properties
    end
    methods
        function obj=test_gen_sqw_accumulate_sqw_parpool(test_name,varargin)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with
            %   previously saved results in
            %   test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same
            %                                           folder as this
            %                                           function
            %   >> test_gen_sqw_accumulate_sqw ('save') % Save to
            %   test_multifit_horace_1_output.mat
            %
            % Reads previously created test data sets.
            
            % constructor
            if ~exist('test_name','var')
                test_name = mfilename('class');
            end
            obj = obj@gen_sqw_common_config(-1,1,'mpi_code','herbert');            
            obj = obj@gen_sqw_accumulate_sqw_tests_common(test_name,'herbert');
        end
        
    end
    
end
