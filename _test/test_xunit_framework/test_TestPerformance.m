classdef test_TestPerformance < TestCase
    properties
        this_path;
    end

    methods
        function self = test_TestPerformance(name)
            if nargin<1
                name = 'test_Performance';
            end
            self = self@TestCase(name);
            self.this_path = fileparts(mfilename('fullpath'));
        end
        %
        function test_get_milti_perf_array_filterd_by_feature(obj)
            tc = pTestPerformanceTester(fullfile(obj.this_path,'TestPerformanceTester_PerfRez.xml'));
            [x_axis,res_sum,res_split] = tc.get_filtered_res('host_172_16_113_202','gen_sqw_slurm_nwk%d_%s',1);
            assertEqual(numel(x_axis),12);
            assertEqual(size(res_sum),[12,3])
            assertEqual(size(res_split),[12,2])
        end
        %
        function test_assert_performance(~)
            tc = pTestPerformanceTester();
            ntp = 10;
            for i=1:ntp
                t1 = tic();
                ss = sum(i:i+10);
                tc.assertPerformance(t1,['some_test_',num2str(i)],...
                    [' some fake test N: ',num2str(i)]);
            end
            perf  = tc.known_performance('some_test_3');
            assertFalse(isempty(perf))
            assertTrue(isfield(perf,'time_sec'));
            known_ds = tc.known_perf_data_names();
            assertEqual(numel(known_ds),1);

            perf1  = tc.known_performance('some_test_3',known_ds{1});
            assertEqual(perf,perf1);
            if is_file('pTestPerformanceTester_PerfRez.xml')
                delete('pTestPerformanceTester_PerfRez.xml');
            end
        end
        function test_get_perf_array_filterd_by_feature(obj)
            tc = pTestPerformanceTester(fullfile(obj.this_path,'TestPerformanceTester_PerfRez.xml'));
            [x_axis,res_sum,res_split] = tc.get_filtered_res('host_172_16_113_202_slurm_mpi_nf100','gen_sqw_slurm_nwk%d_comb_mex_code_MODE1',1);
            assertEqual(numel(x_axis),12);
            assertEqual(size(res_sum),[12,2])
            assertEqual(size(res_split),[12,1])
        end
        %
        function test_filter_perfom_no_ds(~)
            tc = pTestPerformanceTester();
            [res_sum,res_split] = tc.get_filtered_res('host_172_16_113_202_slurm_mpi_nf100',{'nwk','_'});
            assertTrue(isempty(res_sum));
            assertTrue(isempty(res_split));
        end
        %
        function test_got_reference_data(obj)
            tc = pTestPerformanceTester(fullfile(obj.this_path,'TestPerformanceTester_PerfRez.xml'));
            res = tc.perf_data;
            fn = fieldnames(res);
            assertEqual(numel(fn),11);
        end
        %
        function test_got_empy_data_from_tmp_folder(~)
            % creates perf file in the tmp folder
            tc = pTestPerformanceTester('TestSome_PerfRez.xml');
            trf = tc.test_results_file;
            assertFalse(is_file(trf));
            res = tc.known_performance('gen_sqw');
            assertTrue(isempty(res));
            % empty data exist
            res = tc.perf_data;
            assertTrue(isstruct(res));
            if is_file(trf)
                delete(trf);
            end
        end
        %
        function test_suite_nme_is_comp_nme_and_clstr_and_tst_clss_nme(~)
            try
                clob = set_temporary_config_options(parallel_config, 'parallel_cluster', 'mpiexec_mpi');
            catch
                skipTest('mpiexec_mpi cluster is not available on the test machine');
            end

            tc = pTestPerformanceTester();
            name = tc.build_test_suite_name('SomeName');

            com_name = getComputerName();
            p_pos = strfind(com_name,'.');
            if ~isempty(p_pos)
                com_name= com_name(1:p_pos(1)-1);
            end
            assertEqual(name,[com_name,'_','mpiexec_mpi_SomeName']);
        end

        %
        function test_suite_name_is_computer_name_and_test_class_name_for_herbert(~)
            clob = set_temporary_config_options(parallel_config, 'parallel_cluster', 'herbert');

            tc = pTestPerformanceTester();
            name = tc.build_test_suite_name('SomeName');

            com_name = getComputerName();
            p_pos = strfind(com_name,'.');
            if ~isempty(p_pos)
                com_name= com_name(1:p_pos(1)-1);
            end

            assertEqual(name,[com_name,'_','SomeName']);
        end
        %
        function test_default_test_name(~)
            tc = pTestPerformanceTester();
            name = tc.default_PerfTest_fname(mfilename('fullpath'));
            [fp,fn,fe] = fileparts(name);
            assertEqual(fp,fileparts(mfilename('fullpath')));
            assertEqual(fn,'test_TestPerformance_PerfRez');
            assertEqual(fe,'.xml');
        end
        %
        function test_empty_results(~)
            tc = pTestPerformanceTester();
            res = tc.known_performance('some_gen_sqw');
            assertTrue(isempty(res));
        end
        %
        function test_no_known_perf_name(~)
            tc = pTestPerformanceTester();
            try
                tc.known_performance();
                assertTrue(false,'This call should throw invalid_argument exception')
            catch ERR
                if ~strcmp(ERR.identifier,'HERBERT:TestPerformance:invalid_argument')
                    rethrow(ERR);
                end
            end
        end
    end
end
