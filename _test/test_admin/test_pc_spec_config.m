classdef test_pc_spec_config < TestCase
    % Testing default configuration manager, selecting
    % configuration as function of a pc type

    properties
        working_dir;
    end
    methods

        function this=test_pc_spec_config(name)
            if nargin<1
                name = 'test_pc_spec_config';
            end
            this = this@TestCase(name);
            this.working_dir = tmp_dir;
        end
        function test_optimal_config_can_not_have_memory_too_big(~)
            cm = opt_config_manager();
            cm = cm.load_configuration();
            known_configs = cm.known_configurations;

            % lets assume that we have win_small and it has so little
            % memory, that known pc configuration is invalid
            win_small_config = known_configs.win_small;
            % let assume that we have identified pc with current configuration
            % have twice as much memory as we may assume
            hc = win_small_config.hor_config;
            hc.mem_chunk_size = floor(cm.this_pc_memory*2*0.8/opt_config_manager.DEFAULT_PIX_SIZE);
            win_small_config.hor_config = hc;
            known_configs.win_small = win_small_config;
            cm = cm.set_known_configurations(known_configs);


            % optimal configuration in this case should have reasonable
            % amount of memory
            cm.this_pc_type = 'win_small';
            def_config = cm.optimal_config;
            hc = def_config.hor_config;
            assertEqual(hc.mem_chunk_size,floor(cm.this_pc_memory*0.8/opt_config_manager.DEFAULT_PIX_SIZE))
        end

        function test_load_config(~)
            cm = opt_config_manager();
            assertTrue(isempty(cm.optimal_config));

            % The string sets configuration in memory. Should not be used
            % in tests.
            %cm = cm.load_configuration('-set_config','-change_only_default','-force_save');
            cm = cm.load_configuration();
            % Some pc type will be selected.
            assertFalse(isempty(cm.optimal_config));

            % check generic win_small configuration
            cm.this_pc_type = 'win_small';
            def_config = cm.optimal_config;
            assertFalse(def_config.hpc_config.build_sqw_in_parallel);
            assertEqual(def_config.hpc_config.mex_combine_thread_mode,0);
        end

        function test_constructor_and_initial_op(obj)
            clob_par = set_temporary_config_options(parallel_config);
            clob_hc = set_temporary_config_options(hor_config);
            clob_hpc = set_temporary_config_options(hpc_config);

            pc = parallel_config();
            hc = hor_config();
            hpc = hpc_config();

            cm = opt_config_manager();
            source_dir = fileparts(which('opt_config_manager.m'));
            assertEqual(source_dir,cm.config_info_folder);
            % change config info folder to test save/load configuration.
            cm.config_info_folder = obj.working_dir;
            cm.this_pc_type = 'a_mac';
            assertEqual(cm.this_pc_type,'a_mac');

            conf_file = fullfile(cm.config_info_folder,cm.config_filename);
            clob = onCleanup(@()delete(conf_file));
            cm.save_configurations();
            assertTrue(is_file(conf_file));

            ll = hc.log_level;

            % set up different numer of threads
            hc.log_level= ll+1;
            assertEqual(hc.log_level,ll+1);

            cm.load_configuration('-set_config');

            % the previous number of threads have been restored
            assertEqual(hc.log_level,ll);

            % check that the configuration is stored/restored for second time
            cm.this_pc_type = 1;
            hc.log_level = ll+10;
            cm.save_configurations();

            assertTrue(is_file(conf_file));

            hc.log_level=ll;
            cm.this_pc_type = 'a_mac';
            cm.load_configuration('-set_config');
            assertEqual(hc.log_level,ll);
        end

        function test_is_current_idaaas(~)

            is = is_idaaas('some_host_name');
            assertFalse(is);

            is = is_idaaas('host_192_168_243_32');
            assertTrue(is);
        end

        function test_set_wrong_pc_name(~)
            cm = opt_config_manager();
            function pc_type_setter(cm)
                cm.this_pc_type = 'rubbish';
            end
            assertExceptionThrown(@()pc_type_setter(cm),...
                'HERBERT:opt_config_manager:invalid_argument');

        end

        function test_set_wrong_pc_id(~)
            cm = opt_config_manager();
            function pc_type_setter(cm)
                cm.this_pc_type = -1;
            end
            assertExceptionThrown(@()pc_type_setter(cm),...
                'HERBERT:opt_config_manager:invalid_argument');
        end

        function test_set_pc_type_by_id(~)
            cm = opt_config_manager();
            kpc = cm.pc_types;
            ntypes = numel(kpc);
            for i=1:ntypes
                cm.this_pc_type = i;
                assertEqual(cm.this_pc_type,kpc{i});
                assertEqual(cm.pc_config_num,i);
            end
        end

        function test_set_pc_id_by_name(~)
            cm = opt_config_manager();
            kpc = cm.pc_types;
            ntypes = numel(kpc);
            for i=1:ntypes
                cm.this_pc_type = kpc{i};
                assertEqual(cm.this_pc_type,kpc{i});
                assertEqual(cm.pc_config_num,i);
            end

        end

    end
end
