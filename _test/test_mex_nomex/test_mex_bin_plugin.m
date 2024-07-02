classdef test_mex_bin_plugin < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        tmp_data_folder;
        skip_tests;
        current_mex_state;
        current_thread_state;
        sample_dir;
    end

    methods
        function this=test_mex_bin_plugin(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_mex_bin_plugin';
            end
            this = this@TestCase(name);

        end

        function test_bin_c(this)
            if this.skip_tests
                skipTest('MEX not enabled')
            end
            try
                ver = mex_bin_plugin();
                valid = true;
            catch
                valid = false;
            end
            
            assertTrue(valid);
            assertEqual(ver,horace_version)
        end
    end

end
