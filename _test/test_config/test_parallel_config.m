classdef test_parallel_config< TestCase
    % Test basic functionality of configuration classes
    %
    methods
        function obj = test_parallel_config(name)
            if nargin == 0
                name = 'test_parallel_config';
            end
            obj = obj@TestCase(name);
        end

        function obj = test__fake_worker(obj)
            clob = set_temporary_config_options(parallel_config);
            clWn = set_temporary_warning('off','HORACE:parallel_config:invalid_argument');
            pc = parallel_config_tester;

            pc = pc.set_worker('non_existing_worker');

            pc.worker = 'non_existing_worker';
            [~,wid] = lastwarn;
            assertEqual(wid,'HORACE:parallel_config:invalid_argument')
            assertEqual(pc.worker,'non_existing_worker');
            assertEqual(pc.parallel_cluster,'none');
            assertEqual(pc.cluster_config,'none');
        end

        function obj = test__missing_worker(obj)
            clob = set_temporary_config_options(parallel_config);
            pc = parallel_config();

            f = @()set(pc,'worker','non_existing_worker');
            assertExceptionThrown(f,'HORACE:parallel_config:invalid_argument');
        end

        function obj = test__slurm_commands_parser(obj)
            clob = set_temporary_config_options(parallel_config);
            pc = parallel_config();

            % Sets for comparison
            new_commands = containers.Map({'-A' '-p'}, {'account' 'partition'});
            new_commands_app = containers.Map({'-p' '-q'}, {'new_part' 'queue'});
            new_commands_app_check = containers.Map({'-A' '-p' '-q'}, {'account' 'new_part' 'queue'});

            %% Destructive
            % Set as map
            pc.slurm_commands = new_commands;
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            % Set empty (check clearing works)
            pc.slurm_commands = [];
            assertTrue(isempty(pc.slurm_commands))

            % Set as char
            pc.slurm_commands = [];
            pc.slurm_commands = '-A account -p=partition';
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());


            % Set as cellstr of commands
            pc.slurm_commands = [];
            pc.slurm_commands = {'-A' 'account' '-p' 'partition'};
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            % Set as cell array of pairs of commands
            pc.slurm_commands = [];
            pc.slurm_commands = {{'-A' 'account'} {'-p' 'partition'}};
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            % Using update_slurm_commands
            pc.slurm_commands = [];
            pc.update_slurm_commands('-A account -p=partition', false);
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            % Using update_slurm_commands omitting append
            pc.slurm_commands = [];
            pc.update_slurm_commands(new_commands);
            assertEqual(pc.slurm_commands.keys(), new_commands.keys());
            assertEqual(pc.slurm_commands.values(), new_commands.values());

            %% Non-destructive
            % Set through update_slurm_commands as map
            pc.slurm_commands = new_commands;
            pc.update_slurm_commands(new_commands_app, true);
            assertEqual(pc.slurm_commands.keys(), new_commands_app_check.keys());
            assertEqual(pc.slurm_commands.values(), new_commands_app_check.values());

            % Set through update_slurm_commands as char
            pc.slurm_commands = new_commands;
            pc.update_slurm_commands('-q queue -p=new_part', true);
            assertEqual(pc.slurm_commands.keys(), new_commands_app_check.keys());
            assertEqual(pc.slurm_commands.values(), new_commands_app_check.values());

            % Set through Map interface
            pc.slurm_commands = new_commands;
            pc.slurm_commands('-q') = 'queue';
            pc.slurm_commands('-p') = 'new_part';
            assertEqual(pc.slurm_commands.keys(), new_commands_app_check.keys());
            assertEqual(pc.slurm_commands.values(), new_commands_app_check.values());
        end

    end
end
