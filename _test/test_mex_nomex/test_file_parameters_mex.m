classdef test_file_parameters_mex < TestCase
    % TEST_FILE_PARAMETERS_MEX validates plugin wich
    % accepts file parameters from MATLAB.
    % The test plugin returns these parameters back for testing
    % but in actual FileParameters tests these parameters are used for
    % opening and writing/reading pix information

    properties
        skipTests = false;
    end

    methods
        function obj = test_file_parameters_mex(varargin)
            if nargin == 0
                name = 'test_file_parameters_mex';
            else
                name =varargin{1};
            end
            obj= obj@TestCase(name);

            try
                file_parameters_tester();
                obj.skipTests  = false;
            catch
                obj.skipTests  = true;
            end
        end

        function test_missing_requested2_trow(obj)
            if obj.skipTests
                skipTest('Mex is not available or invalid. Can not test fileParameters processing ')
            end
            function res = thrower()
                param = struct('file_name','my_file');
                res = file_parameters_tester(param);
            end

            % tester returns all input parameters
            ex = assertExceptionThrown(@()thrower, ...
                'HORACE:fileParameters:invalid_argument');
            assertTrue(strncmp(ex.message, ...
                'value for field: pix_start_pos requested but has not been provided',20))
        end

        function test_missing_requested1_trow(obj)
            if obj.skipTests
                skipTest('Mex is not available or invalid. Can not test fileParameters processing ')
            end
            function res = thrower()
                param = struct('pix_start_pos',10);
                res = file_parameters_tester(param);
            end

            % tester returns all input parameters
            ex = assertExceptionThrown(@()thrower, ...
                'HORACE:fileParameters:invalid_argument');
            assertTrue(strncmp(ex.message, ...
                'value for field: file_name requested but has not been provided',20))
        end
        function test_all_requests_missing_trow(obj)
            if obj.skipTests
                skipTest('Mex is not available or invalid. Can not test fileParameters processing ')
            end
            function res = thrower()
                param = struct();
                res = file_parameters_tester(param);
            end

            % tester returns all input parameters
            ex = assertExceptionThrown(@()thrower, ...
                'HORACE:fileParameters:invalid_argument');
            assertTrue(strncmp(ex.message, ...
                'value for field: file_name requested but has not been provided',20))
        end

        function test_missing_minimal_set_works(obj)
            if obj.skipTests
                skipTest('Mex is not available or invalid. Can not test fileParameters processing ')
            end
            param = struct('file_name','my_file','npix_start_pos',1,...
            'pix_start_pos',1,'file_id',6,'nbins_total',0,'pixel_with',34);

            % tester returns all input parameters
            test_out = file_parameters_tester(param);
            assertEqual(test_out{1},'my_file');
            assertEqual(test_out{2},1);
            assertEqual(test_out{3},1);
            assertEqual(test_out{4},6);
            assertEqual(test_out{5},0);
            assertEqual(test_out{6},34);
            %const std::map<std::string, int> fileParameters::fileParamNames = {
     %{ std::string("file_name"),0 },
    %{ std::string("npix_start_pos"),1 },
    %{ std::string("pix_start_pos"),2 },
    %{ std::string("file_id"),3 },
    %{ std::string("nbins_total"),4 },
    %{ std::string("npix_total"),5 },
    %{ std::string("pixel_with"),6  }
        end
        function test_all_input_works(obj)
            if obj.skipTests
                skipTest('Mex is not available or invalid. Can not test fileParameters processing ')
            end
            param = struct('file_name','my_file','npix_start_pos',1,...
            'pix_start_pos',1,'file_id',6,'nbins_total',0,'pixel_with',34);

            % tester returns all input parameters
            test_out = file_parameters_tester(param);
            assertEqual(test_out{1},'my_file');
            assertEqual(test_out{2},1);
            assertEqual(test_out{3},1);
            assertEqual(test_out{4},6);
            assertEqual(test_out{5},0);
            assertEqual(test_out{6},34);
        end
    end
end