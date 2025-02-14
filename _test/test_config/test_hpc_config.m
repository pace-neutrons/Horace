classdef test_hpc_config< TestCase
    % Test basic functionality of hpc_config class
    %
    properties
        n_attempts;
    end
    methods
        function obj = test_hpc_config(name)
            if nargin == 0
                name = 'test_hpc_config';
            end
            obj = obj@TestCase(name);

            if is_jenkins
                obj.n_attempts = 10;
            else
                obj.n_attempts = 1;
            end

        end
        function test_get_default_memory_from_config_store(~)
            config_store.instance().clear_config('hpc_config');

            mem = config_store.instance().get_value('hpc_config','phys_mem_available');
            assertFalse(isempty(mem));
            assertTrue(mem>0);

        end

        function test_get_free_memory_from_empty(obj)

            hpc = hpc_config();
            hpc.phys_mem_available = [];

            mem = hpc.phys_mem_available;
            assertTrue(hpc.is_field_configured('phys_mem_available'));
            for i=1:obj.n_attempts
                try
                    % memory in bytes, allocate doubles, divide by 2 for
                    % stability on Jenkins Windows where multiple job
                    % running
                    data = zeros(floor(mem/8/2),1);
                    ok = true;
                    clear data;
                    break
                catch
                    ok = false;
                    % wait for short period of time to allow other instance
                    % of the test job releave its memory
                    if obj.n_attempts>1; pause(1); end
                end
            end
            assertTrue(ok,sprintf(...
                'TEST_GET_FREE_MEMORY_FROM_EMPTY:Can not allocate memory reported as available after %d iterations', ...
                obj.n_attempts));
        end

        function test_get_free_memory(obj)

            hpc = hpc_config();

            mem = hpc.phys_mem_available;
            assertTrue(hpc.is_field_configured('phys_mem_available'));

            for i=1:obj.n_attempts
                try
                    % memory in bytes, allocate doubles, divide by 2 for
                    % stability on Jenkins Windows where multiple job
                    % running
                    data = zeros(floor(mem/8/2),1);
                    ok = true;
                    clear data;
                    break
                catch
                    ok = false;
                    % wait for short period of time to allow other instance
                    % of the test job releave its memory
                    if obj.n_attempts>1; pause(1); end
                end
            end
            assertTrue(ok,sprintf(...
                'TEST_GET_FREE_MEMORY:Can not allocate memory reported as available after %d iterations', ...
                obj.n_attempts));
        end

        function test_mem_works(obj)

            fm = hpc_config.calc_free_memory();
            for i=1:obj.n_attempts
                try
                    % memory in bytes, allocate doubles, divide by 2 for
                    % stability on Jenkins Windows where multiple job
                    % running
                    data = zeros(floor(fm/8/2),1);
                    ok = true;
                    clear data;
                    break
                catch
                    ok = false;
                    % wait for short period of time to allow other instance
                    % of the test job releave its memory
                    if obj.n_attempts>1; pause(1); end
                end
            end
            assertTrue(ok,sprintf( ...
                'TEST_MEM_WORKS:Can not allocate memory reported as available after %d iterations', ...
                obj.n_attempts));
        end
    end
end
