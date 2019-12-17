classdef test_parallel_config_and_fmwks_factory < TestCase
    % Test running using the parpool job dispatcher.
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    properties
    end
    
    methods
        function obj = test_parallel_config_and_fmwks_factory(varargin)
            if ~exist('name','var')
                name = 'test_parallel_config_and_fmwks_factory';
            end
            obj = obj@TestCase(name);
        end
        function test_fmwks_set_get(obj)
            pc = parallel_config;
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.saveable = false;
            clob2 = onCleanup(@()set(pc,'saveable',true));
            
            if strcmpi(pc.parallel_framework,'none')
                should_throw = true;
            else
                should_throw = false;
            end
            
            
            all_fmwk_names = MPI_fmwks_factory.instance().known_frmwks_names;
            assertEqual(numel(all_fmwk_names),3);
            assertEqual(all_fmwk_names{1},'herbert');
            assertEqual(all_fmwk_names{2},'parpool');
            assertEqual(all_fmwk_names{3},'mpiexec_mpi');
            mf = MPI_fmwks_factory.instance();
            try
                mf.parallel_framework = 'her';
                assertEqual(MPI_fmwks_factory.instance().parallel_framework,'herbert');
                all_cfg = MPI_fmwks_factory.instance().get_all_configs();
                assertEqual(numel(all_cfg),1);
                assertEqual(all_cfg{1},'local');
            catch ME
                if ~(should_throw && strcmpi(ME.identifier,'PARALLEL_CONFIG:not_available'))
                    rethrow(ME);
                end
                all_cfg = MPI_fmwks_factory.instance().get_all_configs('herbe');
                assertEqual(numel(all_cfg),1);
                assertEqual(all_cfg{1},'local');
                
            end
            
            
            all_cfg = MPI_fmwks_factory.instance().get_all_configs('parp');
            assertEqual(numel(all_cfg),1);
            assertEqual(all_cfg{1},'default');
            
            all_cfg = MPI_fmwks_factory.instance().get_all_configs('m');
            
            assertTrue(numel(all_cfg)>1);
            % first cluster after changing from paropool to mpiexec_mpi would be 'local'
            assertEqual(all_cfg{1},'local');
            
            try
                mf = MPI_fmwks_factory.instance();
                mf.parallel_framework ='parp';
                assertEqual(mf.parallel_framework,'parpool');
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_available')
                    rethrow(Err);
                end
            end
            %
            try
                mf = MPI_fmwks_factory.instance();
                mf.parallel_framework ='m';
                assertEqual(MPI_fmwks_factory.instance().parallel_framework,'mpiexec_mpi');
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_available')
                    rethrow(Err);
                end
            end
            try
                mf = MPI_fmwks_factory.instance();
                mf.parallel_framework ='non_existent';
                
            catch Err
                assertTrue(strcmpi(Err.identifier,'PARALLEL_CONFIG:invalid_argument'))
            end
            try
                mf = MPI_fmwks_factory.instance();
                mf.parallel_framework ='h';
                assertEqual(MPI_fmwks_factory.instance().parallel_framework,'herbert');
            catch ME
                if ~(should_throw && strcmpi(ME.identifier,'PARALLEL_CONFIG:not_available'))
                    rethrow(ME);
                end
                
            end
        end
        
        function test_parallel_config(obj)
            pc = parallel_config;
            if strcmpi(pc.parallel_framework,'none')
                warning('PARALLEL_CONFIG:not_available',...
                    'Parallel framework is not installed properly. Not tested');
                return
            end
            % define current config data to return it after testing
            cur_config = pc.get_data_to_store();
            clob1 = onCleanup(@()set(pc,cur_config));
            pc.saveable = false;
            clob2 = onCleanup(@()set(pc,'saveable',true));
            
            pc.parallel_framework='her';
            assertEqual(pc.parallel_framework,'herbert');
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
            try
                pc.parallel_framework='parp';
                assertEqual(pc.parallel_framework,'parpool');
                
                all_clcfg = pc.known_clust_configs;
                clust = pc.cluster_config;
                % parpool framework uses only one cluster, defined as default
                % in parallel computing toolbox settings.
                assertEqual(numel(all_clcfg ),1);
                assertEqual(all_clcfg{1},clust);
                assertEqual(clust,'default');
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_available')
                    rethrow(Err);
                end
            end
            
            try
                pc.parallel_framework='m';
                assertEqual(pc.parallel_framework,'mpiexec_mpi');
                
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
                
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_available')
                    rethrow(Err);
                end
            end
            pc.parallel_framework=0;
            assertEqual(pc.parallel_framework,'herbert');
            
            try
                pc.parallel_framework=3;
                assertEqual(pc.parallel_framework,'mpiexec_mpi');
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_available')
                    rethrow(Err);
                end
            end
            
            try
                pc.parallel_framework=2;
                assertEqual(pc.parallel_framework,'parpool');
            catch Err
                if ~strcmp(Err.identifier,'PARALLEL_CONFIG:not_avalable')
                    rethrow(Err);
                end
            end
            
            pc.parallel_framework=1;
            assertEqual(pc.parallel_framework,'herbert');
            clust = pc.cluster_config;
            assertEqual(clust,'local');
        end
        
    end
end

