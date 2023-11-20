classdef test_hpc_config< TestCase
    % Test basic functionality of configuration classes
    %
    methods
        function obj = test_hpc_config(name)
            if nargin == 0
                name = 'test_hpc_config';
            end
            obj = obj@TestCase(name);
        end

        function test_get_free_memory(~)

            hpc = hpc_config();

            mem = hpc.real_memory_available;
            assertTrue(hpc.is_field_configured('real_memory_available'));

            try
                data = zeros(floor(mem/8),1);
                ok = true;
                clear data;
            catch
                ok = false;
            end
            assertTrue(ok,'Can not allocate memory reported as available')
        end

        function test_mem_works(~)
            fm = hpc_config.calc_free_memory();
            try
                data = zeros(floor(fm/8),1);
                ok = true;
                clear data;
            catch
                ok = false;
            end
            assertTrue(ok,'Can not allocate memory reported as available')
        end
    end
end
