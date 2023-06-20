classdef test_hpc_works < TestCase
    % Testing default configuration manager, selecting configuration as function of a pc type

    methods

        function this=test_hpc_works(name)
            if nargin<1
                name = 'test_hpc_works';
            end
            this = this@TestCase(name);
        end

        function test_load_config(obj)
            clOb = set_temporary_config_options(hpc_config);
            pc = hpc_config();

            % Check HPC returns old object
            [old_config,new_hpc_config] = hpc();
            old_dte = old_config.get_data_to_store();
            assertEqual(old_dte, data_2restore);

            % Check HPC off disables features
            hpc('off');
            assertFalse(pc.build_sqw_in_parallel);
            assertFalse(pc.parallel_multifit);


            % Check HPC reset returns recommended features
            hpc('reset');

            new_config = pc.get_data_to_store();
            assertEqual(new_hpc_config,new_config);
        end


    end
end
