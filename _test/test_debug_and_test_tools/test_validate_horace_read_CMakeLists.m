classdef test_validate_horace_read_CMakeLists < TestCase
    % Test that the function to read Horace CMakeLists.txt into
    % validate_horace performs as expected.
    
    properties
        CMakeLists_path
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_validate_horace_read_CMakeLists(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_validate_horace_read_CMakeLists';                
            end            
            self = self@TestCase(name);    
            
            self.CMakeLists_path = fileparts(mfilename('fullpath'));
        end
        
        %--------------------------------------------------------------------------
        function test_2her_0herSys_2hor_0horSys(self)
            % Test with no system tests for Herbert and Horace
            
            pth = self.CMakeLists_path;
            CMakeLists_file = fullfile(pth, 'CMakeLists_2_0_2_0.txt');
            [herbert_tests, herbert_system_tests, horace_tests, horace_system_tests] = ...
                validate_horace_read_CMakeLists (CMakeLists_file);

            % Test output
            assertEqual(herbert_tests, ...
                {'test_admin', 'test_data_loaders'})
            assertEqual(herbert_system_tests, {})
            assertEqual(horace_tests, ...
                {'test_algorithms', 'test_ascii_column_data'})
            assertEqual(horace_system_tests, {})
        end
        
        %--------------------------------------------------------------------------
        function test_2her_0herSys_2hor_1horSys(self)
            % Test with no system tests for Herbert
            
            pth = self.CMakeLists_path;
            CMakeLists_file = fullfile(pth, 'CMakeLists_2_0_2_1.txt');
            [herbert_tests, herbert_system_tests, horace_tests, horace_system_tests] = ...
                validate_horace_read_CMakeLists (CMakeLists_file);

            % Test output
            assertEqual(herbert_tests, ...
                {'test_admin', 'test_data_loaders'})
            assertEqual(herbert_system_tests, {})
            assertEqual(horace_tests, ...
                {'test_algorithms', 'test_ascii_column_data'})
            assertEqual(horace_system_tests, ...
                {'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert'})
        end
        
        %--------------------------------------------------------------------------
        function test_2her_1herSys_0hor_1horSys(self)
            % Test with no (non-system) tests for Horace
            
            pth = self.CMakeLists_path;
            CMakeLists_file = fullfile(pth, 'CMakeLists_2_1_0_1.txt');
            [herbert_tests, herbert_system_tests, horace_tests, horace_system_tests] = ...
                validate_horace_read_CMakeLists (CMakeLists_file);

            % Test output
            assertEqual(herbert_tests, ...
                {'test_admin', 'test_data_loaders'})
            assertEqual(herbert_system_tests, ...
                {'test_mpi/test_ParpoolMPI_Framework'})
            assertEqual(horace_tests, {})
            assertEqual(horace_system_tests, ...
                {'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert'})
        end
        
        %--------------------------------------------------------------------------
        function test_2her_1herSys_2hor_1horSys(self)
            % Test with no tests for Horace
            
            pth = self.CMakeLists_path;
            CMakeLists_file = fullfile(pth, 'CMakeLists_2_1_2_1.txt');
            [herbert_tests, herbert_system_tests, horace_tests, horace_system_tests] = ...
                validate_horace_read_CMakeLists (CMakeLists_file);

            % Test output
            assertEqual(herbert_tests, ...
                {'test_admin', 'test_data_loaders'})
            assertEqual(herbert_system_tests, ...
                {'test_mpi/test_ParpoolMPI_Framework'})
            assertEqual(horace_tests, ...
                {'test_algorithms', 'test_ascii_column_data'})
            assertEqual(horace_system_tests, ...
                {'test_gen_sqw_workflow/test_gen_sqw_accumulate_sqw_herbert'})
        end
        
        %--------------------------------------------------------------------------
    end
end
