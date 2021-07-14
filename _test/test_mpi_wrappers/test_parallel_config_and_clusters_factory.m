classdef test_parallel_config_and_clusters_factory < TestCase
    % Test is using the parpool job dispatcher so will not run if one is
    % not available.
    properties
        skip_cluster_tests
    end
    
    methods
        function obj = test_parallel_config_and_clusters_factory(varargin)
            if ~exist('name', 'var')
                name = 'test_parallel_config_and_clusters_factory';
            end
            obj = obj@TestCase(name);
            pc = parallel_config;
            worker = pc.worker;
            if isempty(which(worker))
                obj.skip_cluster_tests = true;
            else
                obj.skip_cluster_tests= false;
            end
            
        end
        %------------------------------------------------------------------
        function test_cluster_slurm_factory_set_get(~)
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            
            mf = MPI_clusters_factory.instance();
            mf.parallel_cluster = 'slurm_mpi';
            assertEqual(mf.parallel_cluster_name,'slurm_mpi')
            
            all_cfg = mf.get_all_configs();
            assertTrue(numel(all_cfg)==2);
            % first cluster after changing from paropool to mpiexec_mpi would be 'local'
            assertEqual(all_cfg{1},'srun');
            
            cl = mf.parallel_cluster;
            if mf.framework_available
                assertTrue(isa(cl,'ClusterSlurm'));
            else
                assertTrue(isempty(cl));
            end
            %
        end
        %
        function test_cluster_herbert_factory_set_get(~)
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            
            mf = MPI_clusters_factory.instance();
            mf.parallel_cluster = 'herbert';
            assertEqual(mf.parallel_cluster_name,'herbert');
            
            all_cfg = mf.get_all_configs();
            assertTrue(numel(all_cfg)==1);
            % first cluster after changing from parpool to mpiexec_mpi would be 'local'
            % because the first configuration for mpiexec_mpi is 'local'
            assertEqual(all_cfg{1},'local');
            
            cl = mf.parallel_cluster;
            if mf.framework_available
                assertTrue(isa(cl,'ClusterHerbert'));
            else
                assertTrue(isempty(cl));
            end
        end
        %
        function test_cluster_parpool_factory_set_get(~)
            
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            %
            mf = MPI_clusters_factory.instance();
            mf.parallel_cluster = 'parpool';
            assertEqual(mf.parallel_cluster_name,'parpool');
            
            all_cfg = mf.get_all_configs();
            assertEqual(numel(all_cfg),1);
            assertEqual(all_cfg{1},'default');
            
            cl = mf.parallel_cluster;
            if mf.framework_available
                assertTrue(isa(cl,'ClusterParpoolWrapper'));
            else
                assertTrue(isempty(cl));
            end
        end
        %
        function test_cluster_mpiexec_factory_set_get(~)
            
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            
            mf = MPI_clusters_factory.instance();
            mf.parallel_cluster = 'mpiexec_mpi';
            assertEqual(mf.parallel_cluster_name,'mpiexec_mpi');
            
            all_cfg = mf.get_all_configs();
            assertTrue(numel(all_cfg)>1);
            % first cluster config after changing from parpool to 
            % mpiexec_mpi would be 'local'
            assertEqual(all_cfg{1},'local');
            
            cl = mf.parallel_cluster;
            if mf.framework_available
                assertTrue(isa(cl,'ClusterMPI'));
            else
                assertTrue(isempty(cl));
            end
            %
        end
        %------------------------------------------------------------------
        function test_cluster_invalid_factory_set(~)
            try
                mf = MPI_clusters_factory.instance();
                mf.parallel_cluster ='non_existent';
            catch Err
                assertTrue(strcmpi(Err.identifier,...
                    'HERBERT:MPI_clusters_factory:invalid_argument'))
            end
        end
        %
        function test_known_clusters(~)
            
            all_clusters_names = MPI_clusters_factory.instance().known_cluster_names;
            
            pc = parallel_config;
            cl_names = pc.known_clusters;
            assertEqual(all_clusters_names,cl_names)
            
            assertEqual(numel(all_clusters_names),4);
            assertEqual(all_clusters_names{1},'herbert');
            assertEqual(all_clusters_names{2},'parpool');
            assertEqual(all_clusters_names{3},'mpiexec_mpi');
            assertEqual(all_clusters_names{4},'slurm_mpi');
            
        end
        %------------------------------------------------------------------
        function test_parallel_config_herbert(obj)
            if obj.skip_cluster_tests
                skipTest('Herbert cluster setup skipped as parallel worker is not available')
            end
            pc = parallel_config;
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
                assertTrue(strcmp(Err.identifier,'HERBERT:parallel_config:invalid_argument'));
                assertTrue(strcmp(pc.cluster_config,'local'));
            end
        end
        %
        function test_parallel_config_parpool(obj)
            if obj.skip_cluster_tests
                skipTest('Parpool cluster setup skipped as parallel worker is not available')
            end
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.saveable = false;
            clob2 = onCleanup(@()set(pc,'saveable',true));
            
            try
                pc.parallel_cluster='p';
            catch ME
                if strcmp(ME.identifier,'HERBERT:parallel_config:not_available')
                    skipTest(...
                        'Parpool cluster setup skipped as parpool cluster is not available on this machine')
                else
                    rethrow(ME)
                end
            end
            assertEqual(pc.parallel_cluster,'parpool');
            
            all_clcfg = pc.known_clust_configs;
            cl_config = pc.cluster_config;
            assertEqual(numel(all_clcfg),1);
            assertEqual(all_clcfg{1},cl_config);
            assertEqual(cl_config,'default');
            try % current parpool cluster can not have 'local' configuration
                pc.cluster_config = 'local';
            catch Err
                assertTrue(strcmp(Err.identifier,'HERBERT:parallel_config:invalid_argument'));
                assertTrue(strcmp(pc.cluster_config,'default'));
            end
        end
        %
        function test_parallel_config_mpiexec(obj)
            if obj.skip_cluster_tests
                skipTest('mpiexec cluster setup test skipped as parallel worker is not available')
            end
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.saveable = false;
            clob2 = onCleanup(@()set(pc,'saveable',true));
            
            try
                pc.parallel_cluster='m';
            catch ME
                if strcmp(ME.identifier,'HERBERT:parallel_config:not_available')
                    skipTest(...
                        'mpiexec_mpi cluster setup test skipped as mpiexec cluster is not available on this machine')
                else
                    rethrow(ME)
                end
            end
            assertEqual(pc.parallel_cluster,'mpiexec_mpi');
            
            all_clcfg = pc.known_clust_configs;
            cl_config = pc.cluster_config;
            assertTrue(numel(all_clcfg)>1);
            
            % old config stored at the beginning of the test
            old_config = cur_config.cluster_config;
            if ismember(old_config,all_clcfg)
                assertEqual(old_config,cl_config);
            else
                assertEqual(all_clcfg{1},cl_config);
                assertEqual(cl_config,'local');
            end
            
            if ispc
                assertTrue(any(ismember(all_clcfg,'test_win_cluster.win')));
                pc.cluster_config = 'test_win';
                cl_config = pc.cluster_config;
                assertEqual(cl_config,'test_win_cluster.win');
            elseif isunix
                assertTrue(any(ismember(all_clcfg,'test_lnx_cluster.lnx')));
                pc.cluster_config = 'test_lnx';
                cl_config = pc.cluster_config;
                assertEqual(cl_config,'test_lnx_cluster.lnx');
            end
        end
        %
        function test_parallel_config_slurm(obj)
            if obj.skip_cluster_tests
                skipTest('slurm cluster setup test skipped as parallel worker is not available')
            end
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.saveable = false;
            clob2 = onCleanup(@()set(pc,'saveable',true));
            
            try
                pc.parallel_cluster='s';
            catch ME
                if strcmp(ME.identifier,'HERBERT:parallel_config:not_available')
                    skipTest(...
                        'slurm cluster setup test skipped as Slurm cluster manager is not available on this machine')
                else
                    rethrow(ME)
                end
            end
            assertEqual(pc.parallel_cluster,'slurm_mpi');
            
            all_clcfg = pc.known_clust_configs;
            assertEqual(numel(all_clcfg),2);
            
            cl_config = pc.cluster_config;
            assertEqual(cl_config,'srun')
            
        end
    end
end