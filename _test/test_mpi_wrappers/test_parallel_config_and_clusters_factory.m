classdef test_parallel_config_and_clusters_factory < TestCase
    % Test is using the parpool job dispatcher so will not run if one is
    % not available.
    properties
    end

    methods
        function obj = test_parallel_config_and_clusters_factory(varargin)
            if ~exist('name', 'var')
                name = 'test_parallel_config_and_clusters_factory';
            end
            obj = obj@TestCase(name);
        end
        %
        function test_cluster_set_get(obj)
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.saveable = false;
            clob2 = onCleanup(@()set(pc,'saveable',true));

            if strcmpi(pc.parallel_cluster,'none')
                should_throw = true;
            else
                should_throw = false;
            end


            all_clusters_names = MPI_clusters_factory.instance().known_cluster_names;
            assertEqual(numel(all_clusters_names),3);
            assertEqual(all_clusters_names{1},'herbert');
            assertEqual(all_clusters_names{2},'parpool');
            assertEqual(all_clusters_names{3},'mpiexec_mpi');
            mf = MPI_clusters_factory.instance();
            try
                mf.parallel_cluster = 'her';
                assertEqual(MPI_clusters_factory.instance().parallel_cluster,'herbert');
                all_cfg = MPI_clusters_factory.instance().get_all_configs();
                assertEqual(numel(all_cfg),1);
                assertEqual(all_cfg{1},'local');
            catch ME
                if ~(should_throw && strcmpi(ME.identifier,'PARALLEL_CONFIG:not_available'))
                    rethrow(ME);
                end
                all_cfg = MPI_clusters_factory.instance().get_all_configs('herbe');
                assertEqual(numel(all_cfg),1);
                assertEqual(all_cfg{1},'local');

            end


            all_cfg = MPI_clusters_factory.instance().get_all_configs('parp');
            assertEqual(numel(all_cfg),1);
            assertEqual(all_cfg{1},'default');

            all_cfg = MPI_clusters_factory.instance().get_all_configs('m');

            assertTrue(numel(all_cfg)>1);
            % first cluster after changing from paropool to mpiexec_mpi would be 'local'
            assertEqual(all_cfg{1},'local');

            try
                mf = MPI_clusters_factory.instance();
                mf.parallel_cluster ='parp';
                assertEqual(mf.parallel_cluster,'parpool');
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_available')
                    rethrow(Err);
                end
            end
            %
            try
                mf = MPI_clusters_factory.instance();
                mf.parallel_cluster ='m';
                assertEqual(MPI_clusters_factory.instance().parallel_cluster,'mpiexec_mpi');
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_available')
                    rethrow(Err);
                end
            end
            try
                mf = MPI_clusters_factory.instance();
                mf.parallel_cluster ='non_existent';

            catch Err
                assertTrue(strcmpi(Err.identifier,'PARALLEL_CONFIG:invalid_argument'))
            end
            try
                mf = MPI_clusters_factory.instance();
                mf.parallel_cluster ='h';
                assertEqual(MPI_clusters_factory.instance().parallel_cluster,'herbert');
            catch ME
                if ~(should_throw && strcmpi(ME.identifier,'PARALLEL_CONFIG:not_available'))
                    rethrow(ME);
                end

            end
        end
        %
        function test_parallel_config(obj)
            pc = parallel_config;
            if strcmpi(pc.parallel_cluster,'none')
                skipTest('Parallel framework is not installed properly. Not tested');
            end
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.saveable = false;
            clob2 = onCleanup(@()set(pc,'saveable',true));

            pc.parallel_cluster='her';
            assertEqual(pc.parallel_cluster,'herbert');
            all_clcfg = pc.known_clust_configs;
            clust = pc.cluster_config;
            assertEqual(numel(all_clcfg),1);
            assertEqual(all_clcfg{1},clust);
            assertEqual(clust,'local');
            try % current herbert cluster can not have 'Default' configuration
                pc.cluster_config = 'default';
            catch Err
                assertTrue(strcmp(Err.identifier,'PARALLEL_CONFIG:invalid_argument'));
                assertTrue(strcmp(pc.cluster_config,'local'));
            end
            old_pfm = pc.parallel_cluster;
            pc.parallel_cluster='parp';
            if strcmpi(old_pfm,pc.parallel_cluster)
                [wn,wid] = lastwarn();
                assertEqual(wid,'PARALLEL_CONFIG:not_available',wn)
            elseif strcmpi(pc.parallel_cluster,'parpool')
                all_clcfg = pc.known_clust_configs;
                clust = pc.cluster_config;
                % parpool framework uses only one cluster, defined as default
                % in parallel computing toolbox settings.
                assertEqual(numel(all_clcfg ),1);
                assertEqual(all_clcfg{1},clust);
                assertEqual(clust,'default');
            else
                assertFalse(true,'Invalid Framework initialized');
            end

            old_pfm = pc.parallel_cluster;
            pc.parallel_cluster='m';
            if strcmpi(old_pfm,pc.parallel_cluster)
                [mess,wid] = lastwarn();
                assertEqual(wid,'PARALLEL_CONFIG:not_available',mess)
            elseif strcmpi(pc.parallel_cluster,'mpiexec_mpi')
                all_clcfg = pc.known_clust_configs;
                assertTrue(numel(all_clcfg)>1);

                clust = pc.cluster_config;
                % first cluster after changing from paropool to mpiexec_mpi would be 'local'
                assertEqual(clust,'local');
                if ispc()
                    assertTrue(any(ismember(all_clcfg,'test_win_cluster.win')));
                    pc.cluster_config = 'test_win';
                    clust = pc.cluster_config;
                    assertEqual(clust,'test_win_cluster.win');
                else
                    assertTrue(any(ismember(all_clcfg,'test_lnx_cluster.lnx')));
                    pc.cluster_config = 'test_lnx';
                    clust = pc.cluster_config;
                    assertEqual(clust,'test_lnx_cluster.lnx');
                end

            else
                assertFalse(true,'Invalid Framework initialized');
            end
            pc.parallel_cluster=0;
            assertEqual(pc.parallel_cluster,'herbert');

            old_pfm = pc.parallel_cluster;
            pc.parallel_cluster=3;

            if strcmpi(old_pfm,pc.parallel_cluster)
                [mess,wid] = lastwarn();
                assertEqual(wid,'PARALLEL_CONFIG:not_available',mess)
            elseif ~strcmpi(pc.parallel_cluster,'mpiexec_mpi')
                assertFalse(true,'Invalid Framework initialized');
            end

            old_pfm = pc.parallel_cluster;
            pc.parallel_cluster=2;

            if strcmpi(old_pfm,pc.parallel_cluster)
                [mess,wid] = lastwarn();
                assertEqual(wid,'PARALLEL_CONFIG:not_available',mess)
            elseif ~strcmpi(pc.parallel_cluster,'parpool')
                assertFalse(true,'Invalid Framework initialized');
            end

            pc.parallel_cluster=1;
            assertEqual(pc.parallel_cluster,'herbert');
            clust = pc.cluster_config;
            assertEqual(clust,'local');
        end

    end
end
