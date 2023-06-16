classdef test_set_temporary_options < TestCase

    methods
        function obj = test_set_temporary_options(name)
            obj = obj@TestCase(name);
        end

        function test_set_config(obj)
            hc = hor_config;
            mch_sz = hc.mem_chunk_size;

            % Ensure that if function fails things are reset
            safety_clob = onCleanup(@() set(hor_config, 'mem_chunk_size', mch_sz, ...
                                                        'saveable', true));


            clob = set_temporary_config_options(hor_config, 'mem_chunk_size', mch_sz+1);
            assertFalse(hc.saveable);
            assertEqual(hc.mem_chunk_size, mch_sz+1);

            clear clob;

            assertEqual(hc.mem_chunk_size, mch_sz);
            assertTrue(hc.saveable);

        end


        function test_set_warning(obj)
            wa = warning('query', 'MATLAB:singularMatrix');
            % Ensure that if function fails things are reset
            safety_clob = onCleanup(@() warning(wa));

            if wa.state ~= 'on'
                warning('on', 'MATLAB:singularMatrix');
            end

            clob = set_temporary_warning('off', 'MATLAB:singularMatrix');

            ws = warning('query', 'MATLAB:singularMatrix');
            assertEqual(ws.state, 'off');

            clear clob;

            ws = warning('query', 'MATLAB:singularMatrix');
            assertEqual(ws.state, 'on');

        end

        function test_set_config_throws_no_return(obj)
            function thrower()
                hc = hor_config;
                mch_sz = hc.mem_chunk_size;
                set_temporary_config_options(hor_config, 'mem_chunk_size', mch_sz);
            end

            assertExceptionThrown(@thrower, 'TEST:set_temporary_config_option');
        end


        function test_set_warning_throws_no_return(obj)
            function thrower()
                set_temporary_warning('off', 'MATLAB:warning');
            end

            assertExceptionThrown(@thrower, 'TEST:set_temporary_warning');
        end


    end

end
