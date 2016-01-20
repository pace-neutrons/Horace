classdef test_gen_sqw_accumulate_sqw_nomex < test_gen_sqw_accumulate_sqw_mex
    % Series of tests of gen_sqw and associated functions
    % Optionally writes results to output file
    %
    %   >>runtests test_gen_sqw_accumulate_sqw          % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
    %                                           % in the same folder as this function
    %                                        % in the same folder as this function

    %   >> test_gen_sqw_accumulate_sqw ('save') % Save to appropriate test
    %                                            file with 
    
    % Reads previously created test data sets.
    properties       
    end
    
    methods
        function this=test_gen_sqw_accumulate_sqw_nomex(varargin)
            % Series of tests of gen_sqw and associated functions
            % Optionally writes results to output file
            %
            %   >> test_gen_sqw_accumulate_sqw          % Compares with previously saved results in test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same folder as this function
            %   >> test_gen_sqw_accumulate_sqw ('save') 
            %
            % Reads previously created test data sets.
            
            % constructor
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            this = this@test_gen_sqw_accumulate_sqw_mex(name,'nomex');            
            
        end

        
    end
end
